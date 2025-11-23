export const defaultExercises = [
    { id: 'bench_press', name: '벤치 프레스', bodyPart: '가슴' },
    { id: 'incline_bench_press', name: '인클라인 벤치 프레스', bodyPart: '가슴' },
    { id: 'incline_dumbbell_press', name: '인클라인 덤벨 프레스', bodyPart: '가슴' },
    { id: 'dumbbell_fly', name: '덤벨 플라이', bodyPart: '가슴' },
    { id: 'push_up', name: '푸쉬업', bodyPart: '가슴' },
    { id: 'decline_push_up', name: '디클라인 푸쉬업', bodyPart: '가슴' },
    { id: 'incline_push_up', name: '인클라인 푸쉬업', bodyPart: '가슴' },
    { id: 'squat', name: '스쿼트', bodyPart: '하체' },
    { id: 'leg_press', name: '레그 프레스', bodyPart: '하체' },
    { id: 'lunge', name: '런지', bodyPart: '하체' },
    { id: 'bulgarian_split_squat', name: '불가리안 스쿼트', bodyPart: '하체' },
    { id: 'deadlift', name: '데드리프트', bodyPart: '등' },
    { id: 'pull_up', name: '풀업', bodyPart: '등' },
    { id: 'lat_pulldown', name: '랫 풀다운', bodyPart: '등' },
    { id: 'dumbbell_row', name: '덤벨 로우', bodyPart: '등' },
    { id: 'shoulder_press', name: '숄더 프레스', bodyPart: '어깨' },
    { id: 'lateral_raise', name: '사이드 레터럴 레이즈', bodyPart: '어깨' },
    { id: 'pike_push_up', name: '파이크 푸쉬업', bodyPart: '어깨' },
    { id: 'bicep_curl', name: '바벨 컬', bodyPart: '이두' },
    { id: 'dumbbell_curl', name: '덤벨 컬', bodyPart: '이두' },
    { id: 'tricep_extension', name: '트라이셉스 익스텐션', bodyPart: '삼두' },
    { id: 'dumbbell_lying_tricep_extension', name: '덤벨 라잉 트라이셉스 익스텐션', bodyPart: '삼두' },
    { id: 'overhead_extension', name: '오버헤드 익스텐션', bodyPart: '삼두' },
    { id: 'dumbbell_kickback', name: '덤벨 킥백', bodyPart: '삼두' },
    { id: 'dips', name: '딥스', bodyPart: '삼두' },
    { id: 'crunch', name: '크런치', bodyPart: '복근' },
    { id: 'plank', name: '플랭크', bodyPart: '복근' },
];

export const bodyParts = ['전체', '가슴', '등', '하체', '어깨', '이두', '삼두', '복근'];

export const getExercises = () => {
    const custom = JSON.parse(localStorage.getItem('custom_exercises') || '[]');
    return [...defaultExercises, ...custom];
};

export const addCustomExercise = (exercise) => {
    const custom = JSON.parse(localStorage.getItem('custom_exercises') || '[]');
    const newExercise = { ...exercise, id: `custom_${Date.now()}`, isCustom: true };
    const updated = [...custom, newExercise];
    localStorage.setItem('custom_exercises', JSON.stringify(updated));
    return updated;
};

export const deleteCustomExercise = (id) => {
    const custom = JSON.parse(localStorage.getItem('custom_exercises') || '[]');
    const updated = custom.filter(ex => ex.id !== id);
    localStorage.setItem('custom_exercises', JSON.stringify(updated));
    return updated;
};

// For backward compatibility with imports that expect 'exercises'
export const exercises = defaultExercises;
