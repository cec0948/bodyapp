import React, { useState, useEffect } from 'react';
import { format } from 'date-fns';
import { ko } from 'date-fns/locale';
import { X } from 'lucide-react';
import Calendar from './components/Calendar';
import DailyLog from './components/DailyLog';
import RestTimer from './components/RestTimer';
import './index.css';
import Logo from './components/Logo';

function App() {
  const [view, setView] = useState('calendar'); // 'calendar' | 'log'
  const [selectedDate, setSelectedDate] = useState(new Date());
  const [showCopyModal, setShowCopyModal] = useState(false);
  const [dragAction, setDragAction] = useState({ isOpen: false, source: null, target: null });

  // Timer State
  const [timerState, setTimerState] = useState({
    isActive: false,
    initialTime: 0,
    startTime: null
  });

  const [workouts, setWorkouts] = useState(() => {
    const saved = localStorage.getItem('workouts');
    return saved ? JSON.parse(saved) : {};
  });

  useEffect(() => {
    localStorage.setItem('workouts', JSON.stringify(workouts));
  }, [workouts]);

  const currentWorkout = workouts[format(selectedDate, 'yyyy-MM-dd')] || [];

  const handleDateSelect = (date) => {
    setSelectedDate(date);
    setView('log');
  };

  const handleUpdateWorkout = (updatedExercises) => {
    const dateKey = format(selectedDate, 'yyyy-MM-dd');
    setWorkouts(prev => ({
      ...prev,
      [dateKey]: updatedExercises
    }));
  };

  const handleSetComplete = (restTime) => {
    if (restTime > 0) {
      setTimerState({
        isActive: true,
        initialTime: restTime,
        startTime: Date.now()
      });
    }
  };

  const handleCopyFromDate = (date) => {
    const sourceDateKey = format(date, 'yyyy-MM-dd');
    const targetDateKey = format(selectedDate, 'yyyy-MM-dd');
    const sourceExercises = workouts[sourceDateKey] || [];

    if (sourceExercises.length === 0) return;

    const newExercises = sourceExercises.map(ex => ({
      ...ex,
      instanceId: Date.now() + Math.random(), // Ensure unique IDs
      sets: ex.sets.map(s => ({ ...s, isCompleted: false })) // Deep copy sets and reset completion
    }));

    setWorkouts(prev => ({
      ...prev,
      [targetDateKey]: [...(prev[targetDateKey] || []), ...newExercises]
    }));
    setShowCopyModal(false);
  };

  const handleWorkoutDrop = (sourceDate, targetDate) => {
    setDragAction({
      isOpen: true,
      source: sourceDate,
      target: targetDate
    });
  };

  const handleConfirmDragAction = (action) => {
    const { source, target } = dragAction;
    if (!source || !target) return;

    const sourceKey = format(source, 'yyyy-MM-dd');
    const targetKey = format(target, 'yyyy-MM-dd');
    const sourceExercises = workouts[sourceKey] || [];

    if (sourceExercises.length === 0) {
      setDragAction({ isOpen: false, source: null, target: null });
      return;
    }

    const newExercises = sourceExercises.map(ex => ({
      ...ex,
      instanceId: Date.now() + Math.random(),
      sets: ex.sets.map(s => ({ ...s, isCompleted: false }))
    }));

    setWorkouts(prev => {
      const newState = { ...prev };

      // Add to target
      newState[targetKey] = [...(newState[targetKey] || []), ...newExercises];

      // If move, clear source
      if (action === 'move') {
        newState[sourceKey] = [];
      }

      return newState;
    });

    setDragAction({ isOpen: false, source: null, target: null });
  };



  return (
    <div className="app-container">
      <header className="app-header">
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
          <Logo size={32} />
          <h1>BodyApp</h1>
        </div>
        {view === 'log' && (
          <button onClick={() => setView('calendar')} className="text-sm">
            뒤로
          </button>
        )}
      </header>

      <main>
        {view === 'calendar' ? (
          <Calendar
            selectedDate={selectedDate}
            onDateSelect={handleDateSelect}
            workoutDates={Object.keys(workouts).filter(k => workouts[k].length > 0)}
            workouts={workouts}
            onWorkoutDrop={handleWorkoutDrop}
          />
        ) : (
          <div className="daily-log-container">
            <div className="log-header" style={{ marginBottom: '1rem' }}>
              <h2>{format(selectedDate, 'MM월 d일 EEEE', { locale: ko })}</h2>
            </div>
            <DailyLog
              workoutData={currentWorkout}
              onUpdateWorkout={handleUpdateWorkout}
              onCopyTrigger={() => setShowCopyModal(true)}
              onSetComplete={handleSetComplete}
            />
          </div>
        )}
      </main>

      {/* Rest Timer */}
      {timerState.isActive && (
        <RestTimer
          initialTime={timerState.initialTime}
          onClose={() => setTimerState({ ...timerState, isActive: false })}
          onComplete={() => {
            // Optional: Notification or vibration here if not handled in component
          }}
        />
      )}

      {/* Copy Modal (Manual Trigger) */}
      {showCopyModal && (
        <div className="modal-overlay">
          <div className="modal-content" style={{ height: 'auto' }}>
            <div className="modal-header">
              <h3>운동 복사</h3>
              <button onClick={() => setShowCopyModal(false)} className="icon-btn">
                <X size={24} />
              </button>
            </div>
            <p style={{ color: 'var(--text-secondary)', marginBottom: '1rem' }}>
              복사할 날짜를 선택하세요.
            </p>
            <Calendar
              selectedDate={null}
              onDateSelect={handleCopyFromDate}
              workoutDates={Object.keys(workouts).filter(k => workouts[k].length > 0)}
              workouts={workouts}
              onWorkoutDrop={() => { }} // Disable drag in copy modal
            />
          </div>
        </div>
      )}

      {/* Drag & Drop Action Modal */}
      {dragAction.isOpen && (
        <div className="modal-overlay" style={{ alignItems: 'center', justifyContent: 'center' }}>
          <div className="modal-content" style={{ height: 'auto', borderRadius: '24px', maxWidth: '320px' }}>
            <div className="modal-header" style={{ justifyContent: 'center' }}>
              <h3>일정 관리</h3>
            </div>
            <p style={{ textAlign: 'center', marginBottom: '1.5rem', color: 'var(--text-secondary)' }}>
              {dragAction.source && format(dragAction.source, 'M월 d일')}의 운동을<br />
              {dragAction.target && format(dragAction.target, 'M월 d일')}로...
            </p>
            <div style={{ display: 'flex', gap: '1rem', justifyContent: 'center' }}>
              <button
                className="secondary-btn"
                onClick={() => handleConfirmDragAction('copy')}
                style={{ flex: 1 }}
              >
                복사
              </button>
              <button
                className="primary-btn"
                onClick={() => handleConfirmDragAction('move')}
                style={{ flex: 1, padding: '0.8rem' }}
              >
                이동
              </button>
            </div>
            <button
              onClick={() => setDragAction({ isOpen: false, source: null, target: null })}
              style={{ marginTop: '1rem', background: 'transparent', color: 'var(--text-secondary)', width: '100%', border: 'none' }}
            >
              취소
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

export default App;
