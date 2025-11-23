import React from 'react';

const Logo = ({ size = 40, className = '' }) => {
    return (
        <svg
            width={size}
            height={size}
            viewBox="0 0 40 40"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
            className={className}
        >
            <defs>
                <linearGradient id="logoGradient" x1="0" y1="40" x2="40" y2="0" gradientUnits="userSpaceOnUse">
                    <stop stopColor="#6366f1" />
                    <stop offset="1" stopColor="#8b5cf6" />
                </linearGradient>
            </defs>
            <rect width="40" height="40" rx="12" fill="url(#logoGradient)" fillOpacity="0.2" />
            <path
                d="M12 28L12 20C12 15.5817 15.5817 12 20 12C24.4183 12 28 15.5817 28 20V28"
                stroke="url(#logoGradient)"
                strokeWidth="4"
                strokeLinecap="round"
                strokeLinejoin="round"
            />
            <circle cx="20" cy="12" r="3" fill="url(#logoGradient)" />
        </svg>
    );
};

export default Logo;
