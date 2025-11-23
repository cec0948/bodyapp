import React, { useState } from 'react';
import { Plus } from 'lucide-react';
import ExerciseSelector from './ExerciseSelector';
import ExerciseCard from './ExerciseCard';

const DailyLog = ({ workoutData, onUpdateWorkout, onCopyTrigger, onSetComplete }) => {
    const [showSelector, setShowSelector] = useState(false);

    const handleAddExercise = (exercise) => {
        const newExercise = {
            ...exercise,
            instanceId: Date.now(),
            sets: []
        };
        const updatedExercises = [...(workoutData || []), newExercise];
        onUpdateWorkout(updatedExercises);
        setShowSelector(false);
    };

    const handleAddSet = (exerciseIndex, set) => {
        const updatedExercises = [...(workoutData || [])];
        updatedExercises[exerciseIndex].sets.push(set);
        onUpdateWorkout(updatedExercises);
    };

    const handleUpdateSet = (exerciseIndex, setIndex, updatedSet) => {
        const updatedExercises = [...(workoutData || [])];
        updatedExercises[exerciseIndex].sets[setIndex] = updatedSet;
        onUpdateWorkout(updatedExercises);
    };

    const handleDeleteExercise = (exerciseIndex) => {
        const updatedExercises = [...(workoutData || [])];
        updatedExercises.splice(exerciseIndex, 1);
        onUpdateWorkout(updatedExercises);
    };

    return (
        <div className="daily-log">
            <div className="exercises-container">
                {(!workoutData || workoutData.length === 0) && (
                    <div className="empty-state">
                        <p>아직 추가된 운동이 없습니다.</p>
                        <button
                            className="secondary-btn"
                            onClick={onCopyTrigger}
                            style={{ marginTop: '1rem' }}
                        >
                            다른 날짜에서 복사하기
                        </button>
                    </div>
                )}

                {workoutData?.map((ex, idx) => (
                    <ExerciseCard
                        key={ex.instanceId}
                        exercise={ex}
                        sets={ex.sets}
                        onAddSet={(set) => handleAddSet(idx, set)}
                        onUpdateSet={(setIdx, set) => handleUpdateSet(idx, setIdx, set)}
                        onDeleteExercise={() => handleDeleteExercise(idx)}
                        onSetComplete={onSetComplete}
                    />
                ))}
            </div>

            <button
                className="primary-btn floating-fab"
                onClick={() => setShowSelector(true)}
            >
                <Plus size={24} /> 운동 추가
            </button>

            {showSelector && (
                <ExerciseSelector
                    onSelect={handleAddExercise}
                    onClose={() => setShowSelector(false)}
                />
            )}
        </div>
    );
};

export default DailyLog;
