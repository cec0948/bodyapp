import React from 'react';
import {
    format,
    startOfMonth,
    endOfMonth,
    startOfWeek,
    endOfWeek,
    eachDayOfInterval,
    isSameMonth,
    isSameDay,
    addMonths,
    subMonths
} from 'date-fns';
import { ko } from 'date-fns/locale';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import { DndContext, useDraggable, useDroppable, MouseSensor, TouchSensor, useSensor, useSensors } from '@dnd-kit/core';

const CalendarDay = ({ day, stats, isSelected, isCurrentMonth, onClick }) => {
    const dateKey = format(day, 'yyyy-MM-dd');

    // Only draggable if there are workouts
    const { attributes, listeners, setNodeRef: setDragNodeRef, transform, isDragging } = useDraggable({
        id: `drag-${dateKey}`,
        data: { date: day },
        disabled: !stats
    });

    const { setNodeRef: setDropNodeRef, isOver } = useDroppable({
        id: `drop-${dateKey}`,
        data: { date: day }
    });

    const style = transform ? {
        transform: `translate3d(${transform.x}px, ${transform.y}px, 0)`,
        zIndex: 100,
        opacity: 0.8,
        boxShadow: '0 10px 20px rgba(0,0,0,0.3)'
    } : undefined;

    return (
        <div
            ref={setDropNodeRef}
            className={`calendar-day ${!isCurrentMonth ? 'disabled' : ''} ${isSelected ? 'selected' : ''} ${isOver ? 'drop-target' : ''}`}
            onClick={() => onClick(day)}
            style={!isDragging ? undefined : { opacity: 0.3 }} // Style for the original element while dragging
        >
            <div
                ref={setDragNodeRef}
                {...listeners}
                {...attributes}
                style={style}
                className="day-content-wrapper"
            >
                <span className="day-number">{format(day, 'd')}</span>
                {stats && (
                    <div className="day-stats">
                        <div className="stat-total">
                            {stats.totalSets}세트
                        </div>
                        {stats.parts.map((item, idx) => (
                            <div key={idx} className="stat-row">
                                <span className="stat-part">{item.part}</span>
                                <span className="stat-count">{item.count}</span>
                            </div>
                        ))}
                    </div>
                )}
            </div>
        </div>
    );
};

const Calendar = ({ selectedDate, onDateSelect, workoutDates = [], workouts = {}, onWorkoutDrop }) => {
    const [currentMonth, setCurrentMonth] = React.useState(new Date());

    const sensors = useSensors(
        useSensor(MouseSensor, {
            activationConstraint: {
                distance: 10, // Drag starts after 10px movement
            },
        }),
        useSensor(TouchSensor, {
            activationConstraint: {
                delay: 250, // Long press for touch
                tolerance: 5,
            },
        })
    );

    const nextMonth = () => setCurrentMonth(addMonths(currentMonth, 1));
    const prevMonth = () => setCurrentMonth(subMonths(currentMonth, 1));

    const monthStart = startOfMonth(currentMonth);
    const monthEnd = endOfMonth(monthStart);
    const startDate = startOfWeek(monthStart);
    const endDate = endOfWeek(monthEnd);

    const days = eachDayOfInterval({
        start: startDate,
        end: endDate,
    });

    const weekDays = ['일', '월', '화', '수', '목', '금', '토'];

    const getDailyStats = (date) => {
        const dateKey = format(date, 'yyyy-MM-dd');
        const dailyWorkout = workouts[dateKey];

        if (!dailyWorkout || dailyWorkout.length === 0) return null;

        const totalSets = dailyWorkout.reduce((acc, ex) => acc + ex.sets.length, 0);

        // Count sets per body part
        const bodyPartCounts = dailyWorkout.reduce((acc, ex) => {
            acc[ex.bodyPart] = (acc[ex.bodyPart] || 0) + ex.sets.length;
            return acc;
        }, {});

        const bodyPartMap = {
            'Chest': '가슴',
            'Back': '등',
            'Legs': '하체',
            'Shoulders': '어깨',
            'Arms': '팔',
            'Core': '복근',
            'All': '전체'
        };

        const formatBodyPart = (name) => bodyPartMap[name] || name;

        // Get all body parts sorted by count
        const sortedParts = Object.entries(bodyPartCounts)
            .sort((a, b) => b[1] - a[1])
            .map(([part, count]) => ({
                part: formatBodyPart(part),
                count
            }));

        return {
            totalSets,
            parts: sortedParts
        };
    };

    const handleDragEnd = (event) => {
        const { active, over } = event;

        if (active && over && active.id !== over.id) {
            // Extract dates from IDs or data
            const sourceDate = active.data.current.date;
            const targetDate = over.data.current.date;

            // Don't drop on same day (though id check covers this mostly)
            if (!isSameDay(sourceDate, targetDate)) {
                onWorkoutDrop(sourceDate, targetDate);
            }
        }
    };

    return (
        <DndContext sensors={sensors} onDragEnd={handleDragEnd}>
            <div className="calendar-container">
                <div className="calendar-header">
                    <button onClick={prevMonth} className="icon-btn">
                        <ChevronLeft size={24} />
                    </button>
                    <h2>{format(currentMonth, 'yyyy년 MMMM', { locale: ko })}</h2>
                    <button onClick={nextMonth} className="icon-btn">
                        <ChevronRight size={24} />
                    </button>
                </div>

                <div className="calendar-grid">
                    {weekDays.map(day => (
                        <div key={day} className="calendar-day-header">
                            {day}
                        </div>
                    ))}

                    {days.map(day => {
                        const isSelected = isSameDay(day, selectedDate);
                        const isCurrentMonth = isSameMonth(day, monthStart);
                        const stats = getDailyStats(day);

                        return (
                            <CalendarDay
                                key={day.toString()}
                                day={day}
                                stats={stats}
                                isSelected={isSelected}
                                isCurrentMonth={isCurrentMonth}
                                onClick={onDateSelect}
                            />
                        );
                    })}
                </div>
            </div>
        </DndContext>
    );
};

export default Calendar;
