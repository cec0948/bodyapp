import React, { useState, useEffect } from 'react';
import { Search, X, Plus, Trash2 } from 'lucide-react';
import { getExercises, addCustomExercise, deleteCustomExercise, bodyParts } from '../data/exercises';

const ExerciseSelector = ({ onSelect, onClose }) => {
    const [search, setSearch] = useState('');
    const [filter, setFilter] = useState('전체');
    const [allExercises, setAllExercises] = useState([]);
    const [showAddForm, setShowAddForm] = useState(false);
    const [newExerciseName, setNewExerciseName] = useState('');
    const [newExercisePart, setNewExercisePart] = useState('가슴');

    useEffect(() => {
        setAllExercises(getExercises());
    }, []);

    const handleAddCustom = () => {
        if (!newExerciseName.trim()) return;
        const newEx = {
            name: newExerciseName,
            bodyPart: newExercisePart
        };
        const updated = addCustomExercise(newEx);
        setAllExercises(updated);
        setNewExerciseName('');
        setShowAddForm(false);
    };

    const handleDeleteCustom = (e, id) => {
        e.stopPropagation();
        if (window.confirm('이 운동을 삭제하시겠습니까?')) {
            const updated = deleteCustomExercise(id);
            setAllExercises(updated);
        }
    };

    const filteredExercises = allExercises.filter(ex => {
        const matchesSearch = ex.name.toLowerCase().includes(search.toLowerCase());
        const matchesFilter = filter === '전체' || ex.bodyPart === filter;
        return matchesSearch && matchesFilter;
    });

    return (
        <div className="modal-overlay">
            <div className="modal-content">
                <div className="modal-header">
                    <h3>운동 선택</h3>
                    <button onClick={onClose} className="icon-btn">
                        <X size={24} />
                    </button>
                </div>

                <div className="search-bar">
                    <Search size={20} className="search-icon" />
                    <input
                        type="text"
                        placeholder="운동 검색..."
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                        autoFocus
                    />
                </div>

                <div className="filter-chips">
                    {bodyParts.map(part => (
                        <button
                            key={part}
                            className={`chip ${filter === part ? 'active' : ''}`}
                            onClick={() => setFilter(part)}
                        >
                            {part}
                        </button>
                    ))}
                </div>

                {showAddForm ? (
                    <div className="add-custom-form" style={{ padding: '1rem', background: 'rgba(255,255,255,0.05)', borderRadius: '12px', marginBottom: '1rem' }}>
                        <h4 style={{ marginBottom: '0.5rem' }}>새로운 운동 추가</h4>
                        <input
                            type="text"
                            placeholder="운동 이름"
                            value={newExerciseName}
                            onChange={(e) => setNewExerciseName(e.target.value)}
                            style={{ marginBottom: '0.5rem' }}
                        />
                        <div style={{ display: 'flex', gap: '0.5rem', marginBottom: '1rem', overflowX: 'auto' }}>
                            {bodyParts.filter(p => p !== '전체').map(part => (
                                <button
                                    key={part}
                                    className={`chip ${newExercisePart === part ? 'active' : ''}`}
                                    onClick={() => setNewExercisePart(part)}
                                    style={{ fontSize: '0.8rem', padding: '0.3rem 0.8rem' }}
                                >
                                    {part}
                                </button>
                            ))}
                        </div>
                        <div style={{ display: 'flex', gap: '0.5rem' }}>
                            <button className="primary-btn" onClick={handleAddCustom} style={{ flex: 1, padding: '0.5rem' }}>추가</button>
                            <button className="secondary-btn" onClick={() => setShowAddForm(false)} style={{ flex: 1, padding: '0.5rem' }}>취소</button>
                        </div>
                    </div>
                ) : (
                    <button
                        className="secondary-btn"
                        onClick={() => setShowAddForm(true)}
                        style={{ width: '100%', marginBottom: '0.5rem', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '0.5rem' }}
                    >
                        <Plus size={18} /> 직접 입력하기
                    </button>
                )}

                <div className="exercise-list">
                    {filteredExercises.map(ex => (
                        <button
                            key={ex.id}
                            className="exercise-item"
                            onClick={() => onSelect(ex)}
                        >
                            <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                                {/* Placeholder for image */}
                                <div style={{ width: '40px', height: '40px', background: 'rgba(255,255,255,0.1)', borderRadius: '8px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                    <span style={{ fontSize: '1.2rem' }}>💪</span>
                                </div>
                                <div>
                                    <div className="ex-name">{ex.name}</div>
                                    <span className="ex-part">{ex.bodyPart}</span>
                                </div>
                            </div>
                            {ex.isCustom && (
                                <div
                                    onClick={(e) => handleDeleteCustom(e, ex.id)}
                                    style={{ padding: '0.5rem', color: 'var(--danger)', opacity: 0.7 }}
                                >
                                    <Trash2 size={16} />
                                </div>
                            )}
                        </button>
                    ))}
                </div>
            </div>
        </div>
    );
};

export default ExerciseSelector;
