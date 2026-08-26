<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Login - Bacameter</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;600;700&family=Inter:wght@400;500;600&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --navy:        #1a3d6d;
            --navy-deep:   #0f2643;
            --cobalt:      #3d7de0;
            --cobalt-dk:   #2c5fc4;
            --sand:        #e8d9bb;
            --ink:         #12233f;
            --muted:       #5c6b82;
            --glass-bg:    rgba(255, 255, 255, 0.60);
            --glass-brd:   rgba(255, 255, 255, 0.70);
            --error-bg:    #fdecec;
            --error-brd:   #f3b7b7;
            --error-ink:   #b3261e;
        }

        * { box-sizing: border-box; }

        html, body {
            height: 100%;
            margin: 0;
        }

        body {
            font-family: 'Inter', Arial, sans-serif;
            color: var(--ink);
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            padding: 24px;
            position: relative;
            overflow: hidden;

            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            background-attachment: fixed;
        }

        body::before {
            content: '';
            position: absolute;
            inset: 0;
            background: radial-gradient(120% 90% at 50% 38%, transparent 0%, rgba(9, 20, 41, 0.16) 100%);
            pointer-events: none;
        }

        .login-card {
            position: relative;
            z-index: 1;
            width: 100%;
            max-width: 380px;
            background: var(--glass-bg);
            border: 1px solid var(--glass-brd);
            border-radius: 22px;
            padding: 40px 36px 32px;
            backdrop-filter: blur(22px) saturate(160%);
            -webkit-backdrop-filter: blur(22px) saturate(160%);
            box-shadow:
                0 24px 60px -12px rgba(15, 38, 67, 0.35),
                0 2px 8px rgba(15, 38, 67, 0.10),
                inset 0 1px 0 rgba(255, 255, 255, 0.55);
            animation: cardIn 0.6s cubic-bezier(.2, .8, .2, 1) both;
        }

        @keyframes cardIn {
            from { opacity: 0; transform: translateY(14px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        @media (prefers-reduced-motion: reduce) {
            .login-card { animation: none; }
        }

        .brand {
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            margin-bottom: 22px;
        }

        .brand-logo {
            width: 56px;
            height: auto;
            margin-bottom: 14px;
            filter: drop-shadow(0 6px 14px rgba(26, 61, 109, 0.25));
        }

        .brand-eyebrow {
            font-family: 'Space Mono', monospace;
            font-size: 10.5px;
            letter-spacing: 0.16em;
            color: var(--cobalt-dk);
            font-weight: 700;
            text-transform: uppercase;
            margin-bottom: 6px;
        }

        .brand-title {
            font-family: 'Space Grotesk', sans-serif;
            font-size: 28px;
            font-weight: 700;
            color: var(--navy-deep);
            letter-spacing: -0.01em;
            margin: 0;
        }

        .brand-tagline {
            font-size: 12.5px;
            color: var(--muted);
            margin-top: 5px;
        }

        .meter-ticks {
            display: flex;
            align-items: flex-end;
            justify-content: center;
            gap: 5px;
            height: 14px;
            margin: 18px 0 22px;
        }
        .meter-ticks span {
            width: 2px;
            background: var(--navy);
            opacity: 0.25;
            border-radius: 2px;
        }
        .meter-ticks span:nth-child(1) { height: 5px; }
        .meter-ticks span:nth-child(2) { height: 9px; }
        .meter-ticks span:nth-child(3) { height: 14px; background: var(--cobalt); opacity: 1; width: 3px; }
        .meter-ticks span:nth-child(4) { height: 9px; }
        .meter-ticks span:nth-child(5) { height: 5px; }

        .error-banner {
            display: flex;
            align-items: flex-start;
            gap: 8px;
            background: var(--error-bg);
            border: 1px solid var(--error-brd);
            color: var(--error-ink);
            font-size: 13px;
            padding: 10px 12px;
            border-radius: 10px;
            margin-bottom: 16px;
        }
        .error-banner svg { flex-shrink: 0; margin-top: 1px; }

        .field {
            position: relative;
            margin-bottom: 14px;
        }

        .field svg.field-icon {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--muted);
            pointer-events: none;
        }

        .field input {
            width: 100%;
            padding: 13px 14px 13px 42px;
            font-size: 14.5px;
            font-family: 'Inter', sans-serif;
            color: var(--ink);
            background: rgba(255, 255, 255, 0.75);
            border: 1.5px solid rgba(26, 61, 109, 0.14);
            border-radius: 11px;
            outline: none;
            transition: border-color 0.18s ease, box-shadow 0.18s ease, background 0.18s ease;
        }
        .field input::placeholder { color: #93a1b6; }
        .field input:focus {
            border-color: var(--cobalt);
            background: rgba(255, 255, 255, 0.95);
            box-shadow: 0 0 0 4px rgba(61, 125, 224, 0.14);
        }

        .field-toggle {
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            padding: 6px;
            cursor: pointer;
            color: var(--muted);
            display: flex;
            border-radius: 6px;
        }
        .field-toggle:hover { color: var(--navy); background: rgba(26, 61, 109, 0.08); }

        .btn-submit {
            width: 100%;
            padding: 13px 16px;
            margin-top: 6px;
            font-family: 'Inter', sans-serif;
            font-size: 14.5px;
            font-weight: 600;
            color: #fff;
            background: linear-gradient(135deg, var(--cobalt) 0%, var(--cobalt-dk) 100%);
            border: none;
            border-radius: 11px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            box-shadow: 0 10px 24px -8px rgba(44, 95, 196, 0.55);
            transition: transform 0.15s ease, box-shadow 0.15s ease, filter 0.15s ease;
        }
        .btn-submit:hover { transform: translateY(-1px); box-shadow: 0 14px 28px -8px rgba(44, 95, 196, 0.62); filter: brightness(1.04); }
        .btn-submit:active { transform: translateY(0); }
        .btn-submit svg { transition: transform 0.15s ease; }
        .btn-submit:hover svg { transform: translateX(2px); }

        .login-footer {
            position: relative;
            z-index: 1;
            margin-top: 20px;
            text-align: center;
            font-size: 11.5px;
            color: rgba(255, 255, 255, 0.85);
            text-shadow: 0 1px 6px rgba(9, 20, 41, 0.5);
            letter-spacing: 0.02em;
        }

        .login-wrap {
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        @media (max-width: 420px) {
            .login-card { padding: 32px 24px 26px; border-radius: 18px; }
            .brand-title { font-size: 24px; }
        }
    </style>
</head>
<body data-bg="{{ url('img/login-bg.png') }}">
    <div class="login-wrap">
        <div class="login-card">
            <div class="brand">
                <img src="{{ url('img/logo-icon.png') }}" alt="Aurora Tekno Global" class="brand-logo">
                <div class="brand-eyebrow">Aurora Tekno Global</div>
                <h1 class="brand-title">Bacameter</h1>
                <p class="brand-tagline">Monitoring Data Baca Meter</p>
            </div>

            <div class="meter-ticks">
                <span></span><span></span><span></span><span></span><span></span>
            </div>

            {% if error is defined %}
                <div class="error-banner">
                    <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <circle cx="8" cy="8" r="7" stroke="#b3261e" stroke-width="1.4"/>
                        <path d="M8 4.5V8.5" stroke="#b3261e" stroke-width="1.4" stroke-linecap="round"/>
                        <circle cx="8" cy="11" r="0.9" fill="#b3261e"/>
                    </svg>
                    <span>{{ error }}</span>
                </div>
            {% endif %}

            <form method="post" action="{{ url('login') }}">
                <div class="field">
                    <svg class="field-icon" width="17" height="17" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <circle cx="10" cy="6.5" r="3.4" stroke="currentColor" stroke-width="1.5"/>
                        <path d="M3.5 17c0-3.6 2.9-6 6.5-6s6.5 2.4 6.5 6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
                    </svg>
                    <input type="text" name="username" placeholder="Username" required autofocus autocomplete="username">
                </div>

                <div class="field">
                    <svg class="field-icon" width="17" height="17" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <rect x="4.5" y="9" width="11" height="8" rx="2" stroke="currentColor" stroke-width="1.5"/>
                        <path d="M6.5 9V6.5a3.5 3.5 0 0 1 7 0V9" stroke="currentColor" stroke-width="1.5"/>
                    </svg>
                    <input type="password" name="password" id="passwordInput" placeholder="Password" required autocomplete="current-password">
                    <button type="button" class="field-toggle" id="togglePassword" aria-label="Tampilkan password">
                        <svg width="17" height="17" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg" id="eyeIcon">
                            <path d="M1.5 10S4.5 4 10 4s8.5 6 8.5 6-3 6-8.5 6-8.5-6-8.5-6Z" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/>
                            <circle cx="10" cy="10" r="2.4" stroke="currentColor" stroke-width="1.5"/>
                        </svg>
                    </button>
                </div>

                <button type="submit" class="btn-submit">
                    Masuk
                    <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M3.5 8H12.5" stroke="#fff" stroke-width="1.6" stroke-linecap="round"/>
                        <path d="M9 4.5 12.5 8 9 11.5" stroke="#fff" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                </button>
            </form>
        </div>

        <p class="login-footer">Internal Tool &middot; Aurora Tekno Global</p>
    </div>

    <script>
        var bgPath = document.body.dataset.bg;
        if (bgPath) {
            document.body.style.backgroundImage =
                'linear-gradient(180deg, rgba(10,25,50,0.10) 0%, rgba(10,25,50,0.28) 100%), url("' + bgPath + '")';
        }
        var toggleBtn = document.getElementById('togglePassword');
        var pwdInput  = document.getElementById('passwordInput');
        var eyeIcon   = document.getElementById('eyeIcon');

        if (toggleBtn && pwdInput) {
            toggleBtn.addEventListener('click', function () {
                var showing = pwdInput.type === 'text';
                pwdInput.type = showing ? 'password' : 'text';
                toggleBtn.setAttribute('aria-label', showing ? 'Tampilkan password' : 'Sembunyikan password');
                eyeIcon.innerHTML = showing
                    ? '<path d="M1.5 10S4.5 4 10 4s8.5 6 8.5 6-3 6-8.5 6-8.5-6-8.5-6Z" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/><circle cx="10" cy="10" r="2.4" stroke="currentColor" stroke-width="1.5"/>'
                    : '<path d="M2 2l16 16" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/><path d="M1.5 10S4.5 4 10 4c1.1 0 2.1.18 3 .5M18.5 10s-1.2 2.4-3.6 4.1M6.2 15c1.1.6 2.4.9 3.8.9 5.5 0 8.5-6 8.5-6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>';
            });
        }
    </script>
</body>
</html>
