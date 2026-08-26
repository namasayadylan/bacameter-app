<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{% if pageTitle is defined %}{{ pageTitle }} - {% endif %}Bacameter</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;600;700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="{{ url('css/style.css') }}">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css">
    {% block head %}{% endblock %}
</head>
<body>
    <header class="topbar">
        <div class="topbar-top">
            <div class="topbar-brand">
                <img src="{{ url('img/logo-icon.png') }}" alt="Aurora Tekno Global" class="topbar-logo-img">
                <span class="topbar-title">Aurora System</span>
            </div>

            <div class="topbar-account">
                <span class="topbar-role">{{ currentUser['role'] is defined and currentUser['role'] ? currentUser['role'] : 'User' }}</span>
                <span class="topbar-avatar"><img src="{{ url('img/profile.png') }}" alt="Foto profil"></span>
                <div class="topbar-more">
                    <button type="button" class="topbar-more-btn" id="topbarMoreBtn">⋮</button>
                    <div class="topbar-more-list" id="topbarMoreList">
                        <div class="topbar-more-name">{{ currentUser['nama'] is defined ? currentUser['nama'] : '-' }}</div>
                        <div class="topbar-more-user">@{{ currentUser['username'] is defined ? currentUser['username'] : '-' }}</div>
                    </div>
                </div>
            </div>
        </div>

        <nav class="topbar-nav">
            <div class="topbar-nav-left">
                <a href="{{ url('dashboard') }}" class="nav-item {% if (activeMenu is defined) and (activeMenu == 'dashboard') %}active{% endif %}">
                    Dashboard
                </a>

                <div class="nav-item nav-dropdown {% if (activeMenu is defined) and (activeMenu == 'petugas' or activeMenu == 'anomali') %}active{% endif %}">
                    <span class="nav-dropdown-label">Master</span>
                    <div class="nav-dropdown-list">
                        <a href="{{ url('petugas') }}" class="{% if (activeMenu is defined) and (activeMenu == 'petugas') %}active{% endif %}">Petugas</a>
                        <a href="{{ url('anomali') }}" class="{% if (activeMenu is defined) and (activeMenu == 'anomali') %}active{% endif %}">Anomali</a>
                    </div>
                </div>

                <a href="{{ url('datameter') }}" class="nav-item {% if (activeMenu is defined) and (activeMenu == 'datameter') %}active{% endif %}">
                    Pengolahan Data
                </a>
                <a href="{{ url('laporan') }}" class="nav-item {% if (activeMenu is defined) and (activeMenu == 'laporan') %}active{% endif %}">
                    Laporan
                </a>
            </div>

            <a href="{{ url('logout') }}" class="nav-logout">
                Logout
            </a>
        </nav>
    </header>

    <main class="app-content">
        {% if session.has('flash_success') %}
            <div class="alert alert-success">{{ session.get('flash_success') }}</div>
            {% do session.remove('flash_success') %}
        {% endif %}
        {% if session.has('flash_error') %}
            <div class="alert alert-error">{{ session.get('flash_error') }}</div>
            {% do session.remove('flash_error') %}
        {% endif %}
        {% block content %}{% endblock %}
    </main>

    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script src="{{ url('js/app.js') }}"></script>
    {% block scripts %}{% endblock %}
</body>
</html>
