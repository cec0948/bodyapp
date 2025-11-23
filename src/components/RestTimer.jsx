import React, { useState, useEffect, useRef } from 'react';
import { X, Timer } from 'lucide-react';

const RestTimer = ({ initialTime, onComplete, onClose }) => {
    const [timeLeft, setTimeLeft] = useState(initialTime);
    const [isActive, setIsActive] = useState(true);
    const audioRef = useRef(null);

    useEffect(() => {
        setTimeLeft(initialTime);
        setIsActive(true);
    }, [initialTime]);

    useEffect(() => {
        let interval = null;
        if (isActive && timeLeft > 0) {
            interval = setInterval(() => {
                setTimeLeft(prev => prev - 1);
            }, 1000);
        } else if (timeLeft === 0 && isActive) {
            setIsActive(false);
            if (audioRef.current) {
                audioRef.current.play().catch(e => console.log('Audio play failed', e));
            }
            if (onComplete) onComplete();
        }
        return () => clearInterval(interval);
    }, [isActive, timeLeft, onComplete]);

    const formatTime = (seconds) => {
        const m = Math.floor(seconds / 60);
        const s = seconds % 60;
        return `${m}:${s.toString().padStart(2, '0')}`;
    };

    const addTime = (seconds) => {
        setTimeLeft(prev => prev + seconds);
        setIsActive(true);
    };

    if (!isActive && timeLeft === 0) {
        // Timer finished state
        return (
            <div className="rest-timer-overlay finished">
                <div className="rest-timer-content">
                    <h3>휴식 종료!</h3>
                    <button onClick={onClose} className="primary-btn">운동 시작</button>
                    <audio ref={audioRef} src="https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3" />
                </div>
            </div>
        );
    }

    return (
        <div className="rest-timer-floating">
            <div className="timer-header">
                <Timer size={16} />
                <span>휴식 시간</span>
                <button onClick={onClose} className="close-timer">
                    <X size={14} />
                </button>
            </div>
            <div className="timer-display">
                {formatTime(timeLeft)}
            </div>
            <div className="timer-controls">
                <button onClick={() => addTime(10)}>+10초</button>
                <button onClick={() => addTime(30)}>+30초</button>
            </div>
        </div>
    );
};

export default RestTimer;
