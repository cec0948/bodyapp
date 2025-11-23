import React, { useState } from 'react';
import { Plus, Trash2 } from 'lucide-react';

const ExerciseCard = ({ exercise, sets, onAddSet, onUpdateSet, onDeleteExercise, onSetComplete }) => {
    const [weight, setWeight] = useState('');
    const [reps, setReps] = useState('');
    const [restTime, setRestTime] = useState('60'); // Default 60s

    const handleAdd = () => {
        if (weight && reps) {
            onAddSet({
                weight,
                reps,
                restTime: parseInt(restTime) || 60,
                isCompleted: false
            });
            // Keep weight and rest time for next set, clear reps? or keep all?
            // Usually weight stays same. Reps might change.
            // Let's keep weight and restTime.
        }
    };

    const toggleSetCompletion = (idx) => {
        const set = sets[idx];
        const newCompleted = !set.isCompleted;

        onUpdateSet(idx, { ...set, isCompleted: newCompleted });

        if (newCompleted && onSetComplete) {
            onSetComplete(set.restTime || 60);
        }
    };

    return (
        <div className="exercise-card">
            <div className="card-header">
                <h4>{exercise.name}</h4>
                <button onClick={onDeleteExercise} className="icon-btn danger">
                    <Trash2 size={18} />
                </button>
            </div>

            <div className="sets-list">
                <div className="set-header">
                    <span>세트</span>
                    <span>kg</span>
                    <span>회</span>
                    <span>휴식</span>
                </div>
                {sets.map((set, idx) => (
                    <div
                        key={idx}
                        className={`set-row ${set.isCompleted ? 'completed' : ''}`}
                        onClick={() => toggleSetCompletion(idx)}
                        style={{ cursor: 'pointer' }}
                    >
                        <span className="set-num">{idx + 1}</span>
                        <span>{set.weight}</span>
                        <span>{set.reps}</span>
                        <span style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>{set.restTime}s</span>
                    </div>
                ))}
            </div>

            <div className="add-set-row" style={{ gridTemplateColumns: '40px 1fr 1fr 1fr 44px' }}>
                <span className="set-num-placeholder">{sets.length + 1}</span>
                <input
                    type="number"
                    placeholder="kg"
                    value={weight}
                    onChange={e => setWeight(e.target.value)}
                    className="set-input"
                />
                <input
                    type="number"
                    placeholder="회"
                    value={reps}
                    onChange={e => setReps(e.target.value)}
                    className="set-input"
                />
                <input
                    type="number"
                    placeholder="휴식(초)"
                    value={restTime}
                    onChange={e => setRestTime(e.target.value)}
                    className="set-input"
                />
                <button onClick={handleAdd} className="add-set-btn">
                    <Plus size={20} />
                </button>
            </div>
        </div>
    );
};

export default ExerciseCard;
