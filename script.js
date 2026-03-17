/* ─────────────────────────────────────────
   BASE PATH DETECTION
───────────────────────────────────────── */
const getBasePath = () => {
    if (window.location.protocol === 'file:') {
        const href = window.location.href;
        const lastSlash = href.lastIndexOf('/');
        return lastSlash >= 0 ? href.substring(0, lastSlash + 1) : '';
    }
    const pathname = window.location.pathname;
    const parts = pathname.replace(/^\/|\/$/g, '').split('/');
    if (parts.length > 0 && parts[0] && parts[0] !== 'index.html') {
        if (window.location.hostname !== 'localhost' && window.location.hostname !== '127.0.0.1') {
            return `/${parts[0]}`;
        }
    }
    if (pathname !== '/' && pathname !== '/index.html' && pathname.includes('/')) {
        const match = pathname.match(/^\/([^\/]+)/);
        if (match && match[1] && match[1] !== 'index.html') {
            return `/${match[1]}`;
        }
    }
    return '';
};

const BASE_PATH = getBasePath();
const IS_FILE = window.location.protocol === 'file:';

/* ─────────────────────────────────────────
   FILE STRUCTURE
───────────────────────────────────────── */
const fileStructure = {
    "README.md": "README.md",
    "Frontend": {
        "JavaScript": "Frameworks/Frontend/basics/js.md",
        "TypeScript": "Frameworks/Frontend/basics/TypeScript.md",
        "HTML": "Frameworks/Frontend/basics/html.md",
        "CSS": "Frameworks/Frontend/basics/css.md",
        "React": "Frameworks/Frontend/React/React.md",
        "React Native": "Frameworks/Frontend/React/React-Native-Interview-QA.md",
        "Angular": "Frameworks/Frontend/Angular/Angular.md",
        "HTML Playground": "Frameworks/Frontend/basics/html-interview-prep.html"
    },
    "Backend": {
        "Ruby": "Programming/Ruby.md",
        "Go": "Programming/Go.md",
        ".NET/C#": "Frameworks/Backend/dotNet/00_INDEX.md",
        "Ruby on Rails": "Frameworks/Backend/Rails/Ruby on Rails.md",
        "Node.js": "Frameworks/Backend/node/Node.md",
        "Node.js Interview Prep (HTML)": "Frameworks/Backend/node/nodejs-interview-prep.html",
        "Java & Spring Boot (50+ Q&A)": "Frameworks/Backend/Java-Spring-Boot-Interview-QA.md",
        "Python, Django & FastAPI (50+ Q&A)": "Frameworks/Backend/Python-Django-FastAPI-Interview-QA.md"
    },
    "Databases": {
        "MySQL": "Databases/mysql.md",
        "PostgreSQL": "Databases/postgresql.md",
        "MongoDB": "Databases/mongodb.md"
    },
    "Design": {
        "SOLID Principles": "design/SOLID-Principles/SOLID Principles Complete Guide.md",
        "Design Patterns": {
            "Introduction": "design/Design-Patterns/intro.md",
            "Quick Reference": "design/Design-Patterns/Quick Reference Guide.md",
            "Creational": {
                "Singleton": "design/Design-Patterns/Creational/Singleton.md",
                "Factory": "design/Design-Patterns/Creational/Factory.md",
                "Abstract Factory": "design/Design-Patterns/Creational/Abstract Factory.md",
                "Builder": "design/Design-Patterns/Creational/Builder.md",
                "Prototype": "design/Design-Patterns/Creational/Prototype.md"
            },
            "Structural": {
                "Adapter": "design/Design-Patterns/Structural/Adapter.md",
                "Bridge": "design/Design-Patterns/Structural/Bridge.md",
                "Composite": "design/Design-Patterns/Structural/Composite.md",
                "Decorator": "design/Design-Patterns/Structural/Decorator.md",
                "Facade": "design/Design-Patterns/Structural/Facade.md",
                "Flyweight": "design/Design-Patterns/Structural/Flyweight.md",
                "Proxy": "design/Design-Patterns/Structural/Proxy.md"
            },
            "Behavioral": {
                "Chain of Responsibility": "design/Design-Patterns/Behavioral/Chain of Responsibility.md",
                "Command": "design/Design-Patterns/Behavioral/Command.md",
                "Interpreter": "design/Design-Patterns/Behavioral/Interpreter.md",
                "Iterator": "design/Design-Patterns/Behavioral/Iterator.md",
                "Mediator": "design/Design-Patterns/Behavioral/Mediator.md",
                "Memento": "design/Design-Patterns/Behavioral/Memento.md",
                "Observer": "design/Design-Patterns/Behavioral/Observer.md",
                "State": "design/Design-Patterns/Behavioral/State.md",
                "Strategy": "design/Design-Patterns/Behavioral/Strategy.md",
                "Template Method": "design/Design-Patterns/Behavioral/Template Method.md",
                "Visitor": "design/Design-Patterns/Behavioral/Visitor.md"
            }
        },
        "Object-Oriented Design": {
            "OOD Concepts": "design/Object-Oriented-Design/OOD.md",
            "Delivery System OOD": "design/Object-Oriented-Design/Delivery System OOD.md"
        }
    },
    "System Design": {
        "System Design Fundamentals": "System Design/System Design.md",
        "System Design Cheatsheet": "System Design/System Design Cheatsheet.md",
        "HR System Example": "System Design/examples/HR System.md",
        "Delivery System Example": "System Design/examples/Delivery System.md"
    },
    "Architecture": {
        "Microservices": "Architecture/Microservices.md",
        "Event-Driven Architecture": "Architecture/Event-Driven Architecture.md",
        "APIs": "Architecture/APIs.md",
        "Distributed Systems": "Architecture/Distributed Systems.md"
    },
    "Infrastructure": {
        "Docker": "Infrastructure/Docker.md",
        "Kubernetes": "Infrastructure/Kubernetes.md"
    },
    "DevOps": {
        "DevOps Fundamentals": "DevOps/DevOps.md",
        "CI/CD": "DevOps/CI_CD.md",
        "Observability": "DevOps/Observability.md"
    },
    "Caching & Messaging": {
        "Redis": "caching-messaging/Redis.md",
        "RabbitMQ": "caching-messaging/RabbitMQ.md",
        "Kafka": "caching-messaging/Kafka.md"
    },
    "Problem Solving": {
        "Overview": "Problem Solving/Readme.md",
        "DeepSeek Notes": "Problem Solving/deepseek.md",
        "75 LeetCode (HTML)": "Problem Solving/75leetcode.html",
        "Patterns (HTML)": "Problem Solving/patterns.html",
        "LeetCode": {
            "Sliding Window (MD)": "Problem Solving/leetcode/study_plan75/sliding_window.md",
            "Merge Two Sorted Lists": "Problem Solving/leetcode/21. Merge Two Sorted Lists.rb",
            "Two Sum (Combinations)": "Problem Solving/leetcode/77. Combinations.rb",
            "Climbing Stairs": "Problem Solving/leetcode/70. Climbing Stairs.rb",
            "House Robber": "Problem Solving/leetcode/198. House Robber.rb"
        },
        "Data Structures": {
            "Linked List": "Problem Solving/data-structure/linkedlist/linked_list.rb",
            "Binary Search Tree": "Problem Solving/data-structure/tree/binary_search_tree.rb",
            "Trie": "Problem Solving/data-structure/trie/trie.rb"
        },
        "HackerRank": {
            "Two Strings": "Problem Solving/hacker-rank/two_string.rb",
            "Counting Valleys": "Problem Solving/hacker-rank/counting_vally.rb"
        },
        "DSA (Data Structures & Algorithms)": "Problem Solving/Data-Structures-Algorithms/AI mock interview.md"
    },
    "Companies": {
        "Toters": {
            "Full Interview Guide": "Companies/toters/full_interview.md",
            "Technical Deep Dive": "Companies/toters/technical_deep_dive_interview.md",
            "Staff Backend Engineer Q&A": "Companies/toters/Toters Staff Backend Engineer Interview Questions and Answers.md"
        },
        "Amazon": {
            "SDE Interview Preparation": "Companies/Amazon/Amazon SDE Interview Preparation Guide.md",
            "Leadership Principles": "Companies/Amazon/Leadership Principles/index.md",
            "Behavioral Questions": "Companies/Amazon/Behavioral/index.md"
        },
        "Oracle": {
            "Interview Guide": "Companies/oracle/interview_guide.md",
            "Principal Engineer Q&A": "Companies/oracle/Oracle_Principal_Engineer_MASTER_Interview_100_QA.md",
            "OCI Principal Interview": "Companies/oracle/OCI_Principal_Interview_Prep_50_QA.md",
            "Glassdoor": "Companies/oracle/Glassdoor.md"
        },
        "Yassir": {
            "Staff Backend Engineer": "Companies/yassir/Comprehensive Interview Study Guide_ Backend Staff Engineer (Node.js) at Yassir.md",
            "ChatGPT Q&A": "Companies/yassir/chatgpt_QA.md"
        },
        "Other": {
            "Lucidya": "Companies/Lucidya Backend Team Lead Interview Preparation Guide.md",
            "Sanofi": "Companies/Sanofi/interview_questions.md",
            "GoBrands": "Companies/Gobrand/GoBrands.md"
        }
    },
    "Resume & Career": {
        "Interview Preparation Cheatsheet": "Resume-Career/Interview-Preparation-Cheatsheet.md",
        "ATS Optimized CV": "Resume-Career/Hany Sayed Ahmed - ATS Optimized CV.md",
        "FAANG Interview Q&A": "Resume-Career/FAANG Interview Preparation - Extended Q&A.md",
        "Staff Engineer Q&A": "Resume-Career/staff Q&A.md",
        "Study Guide": "Resume-Career/study_guide.md",
        "Behavioral Interview Q&A": "Resume-Career/Behavioral-Interview-QA.md",
        "Behavioral Questions & Answers (50+)": "Resume-Career/Behavioral-Questions-Answers.md",
        "Staff & Leadership Q&A": "Resume-Career/Staff-Leadership-QA.md",
        "Vector Search & AI/ML Q&A": "Resume-Career/Vector-Search-AI-ML-QA.md",
        "Communication": "Resume-Career/Communication/index.md"
    },
    "Specialized Topics": {
        "Senior AI Engineer": "specialized/LLM/Senior AI Engineer Interview.md",
        "Free LLM Resources": "specialized/LLM/FreeLLM.md",
        "AI Engineering Playground": "specialized/LLM/ai-engineering-interview-prep.html",
        "Designing Data-Intensive Apps": "specialized/Books/Design Data Insentive/designing_data_intensive_applications_summary.md"
    },
    "Playgrounds": {
        "Node.js": "Frameworks/Backend/node/nodejs-interview-prep.html",
        "Ruby & Rails": "Frameworks/Backend/Rails/ruby-rails-interview-prep.html",
        "C# & .NET": "Frameworks/Backend/dotNet/dotnet-interview-prep.html",
        "Database": "Databases/database-interview-prep.html",
        "HTML": "Frameworks/Frontend/basics/html-interview-prep.html",
        "System Design": "System Design/system-design-interview-prep.html",
        "DevOps & Infrastructure": "DevOps/devops-infrastructure-interview-prep.html",
        "Design (SOLID, Patterns, OOD)": "design/design-interview-prep.html",
        "Behavioral & Leadership": "Resume-Career/behavioral-leadership-interview-prep.html",
        "AI Engineering": "specialized/LLM/ai-engineering-interview-prep.html"
    }
};

/* ─────────────────────────────────────────
   STATE
───────────────────────────────────────── */
let currentFile = null;
let navHistory = [];

/* ─────────────────────────────────────────
   INIT
───────────────────────────────────────── */
document.addEventListener('DOMContentLoaded', () => {
    loadTheme();
    buildTree();
    bindEvents();

    if (window.location.hash) {
        const f = decodeURIComponent(window.location.hash.slice(1));
        loadFile(f, false);
    } else {
        showWelcome();
    }
});

/* ─────────────────────────────────────────
   THEME
───────────────────────────────────────── */
function loadTheme() {
    const t = localStorage.getItem('theme') || 'dark';
    document.documentElement.setAttribute('data-theme', t);
}

function toggleTheme() {
    const curr = document.documentElement.getAttribute('data-theme');
    const next = curr === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', next);
    localStorage.setItem('theme', next);
}

/* ─────────────────────────────────────────
   SIDEBAR
───────────────────────────────────────── */
function openSidebar() {
    document.getElementById('sidebar').classList.add('open');
    document.getElementById('overlay').classList.add('show');
}
function closeSidebar() {
    document.getElementById('sidebar').classList.remove('open');
    document.getElementById('overlay').classList.remove('show');
}

/* ─────────────────────────────────────────
   EVENTS
───────────────────────────────────────── */
function bindEvents() {
    document.getElementById('menuBtn').addEventListener('click', openSidebar);
    document.getElementById('sidebarClose').addEventListener('click', closeSidebar);
    document.getElementById('overlay').addEventListener('click', closeSidebar);

    document.getElementById('themeBtn').addEventListener('click', toggleTheme);

    document.getElementById('backBtn').addEventListener('click', () => {
        if (navHistory.length > 1) {
            navHistory.pop();
            const prev = navHistory.pop();
            loadFile(prev, false);
        }
    });

    const searchInput = document.getElementById('searchInput');
    const searchClear = document.getElementById('searchClear');

    searchInput.addEventListener('input', (e) => {
        const v = e.target.value;
        filterTree(v);
        searchClear.style.display = v ? 'flex' : 'none';
    });

    searchClear.addEventListener('click', () => {
        searchInput.value = '';
        filterTree('');
        searchClear.style.display = 'none';
        searchInput.focus();
    });

    window.addEventListener('popstate', (e) => {
        if (e.state?.file) {
            loadFile(e.state.file, false);
        } else if (!window.location.hash) {
            showWelcome();
        }
    });

    window.addEventListener('hashchange', () => {
        const f = window.location.hash.slice(1);
        if (f) loadFile(decodeURIComponent(f), false);
        else showWelcome();
    });
}

/* ─────────────────────────────────────────
   FILE TREE
───────────────────────────────────────── */
function buildTree() {
    const nav = document.getElementById('fileTree');
    nav.innerHTML = '';
    nav.appendChild(buildNode(fileStructure, 0));
}

function buildNode(struct, level) {
    const wrap = document.createElement('div');

    for (const [key, val] of Object.entries(struct)) {
        if (typeof val === 'string') {
            wrap.appendChild(makeFileItem(key, val, level));
        } else {
            wrap.appendChild(makeFolderItem(key, val, level));
        }
    }

    return wrap;
}

const CODE_EXTENSIONS = /\.(rb|js|ts|py|java|cpp|c|go|rs|kt|scala)$/i;

function makeFileItem(name, path, level) {
    const el = document.createElement('div');
    el.className = 'tree-file';
    el.setAttribute('data-path', path);
    el.style.paddingLeft = `${1 + level * 1.1}rem`;
    const isHtml = path.endsWith('.html');
    const isCode = CODE_EXTENSIONS.test(path);
    const icon = isHtml ? '🔗' : (isCode ? '💻' : '📄');
    el.innerHTML = `<span class="tree-file-icon">${icon}</span><span>${name}</span>`;
    el.addEventListener('click', () => {
        if (isHtml) {
            const full = BASE_PATH ? `${BASE_PATH}/${path}` : path;
            window.open(full, '_blank');
        } else {
            loadFile(path);
        }
        if (window.innerWidth <= 768) closeSidebar();
    });
    return el;
}

function makeFolderItem(name, children, level) {
    const folder = document.createElement('div');
    folder.className = 'folder';

    const header = document.createElement('div');
    header.className = 'folder-header';
    header.style.paddingLeft = `${0.75 + level * 1.1}rem`;
    header.innerHTML = `
        <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
            <polyline points="9 18 15 12 9 6"/>
        </svg>
        <span>${name}</span>
    `;
    header.addEventListener('click', (e) => {
        e.stopPropagation();
        folder.classList.toggle('open');
    });

    const content = document.createElement('div');
    content.className = 'folder-content';
    content.appendChild(buildNode(children, level + 1));

    folder.appendChild(header);
    folder.appendChild(content);
    return folder;
}

function filterTree(term) {
    const files = document.querySelectorAll('.tree-file');
    const folders = document.querySelectorAll('.folder');

    if (!term) {
        files.forEach(f => f.style.display = '');
        folders.forEach(f => { f.style.display = ''; f.classList.remove('open'); });
        return;
    }

    const low = term.toLowerCase();
    files.forEach(f => {
        const match = f.textContent.toLowerCase().includes(low);
        f.style.display = match ? '' : 'none';
        if (match) {
            // expand parent folders
            let p = f.parentElement;
            while (p) {
                if (p.classList.contains('folder')) p.classList.add('open');
                if (p.classList.contains('file-tree')) break;
                p = p.parentElement;
            }
        }
    });

    folders.forEach(f => {
        const hasVisible = f.querySelector('.tree-file:not([style*="display: none"])');
        f.style.display = hasVisible ? '' : 'none';
    });
}

function setActiveFile(path) {
    document.querySelectorAll('.tree-file.active').forEach(el => el.classList.remove('active'));
    const el = document.querySelector(`.tree-file[data-path="${CSS.escape(path)}"]`);
    if (!el) return;
    el.classList.add('active');
    // expand parents
    let p = el.parentElement;
    while (p) {
        if (p.classList.contains('folder')) p.classList.add('open');
        if (p.classList.contains('file-tree')) break;
        p = p.parentElement;
    }
    el.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

/* ─────────────────────────────────────────
   BREADCRUMB
───────────────────────────────────────── */
function setBreadcrumb(filePath) {
    const bc = document.getElementById('breadcrumb');
    if (!filePath) {
        bc.innerHTML = '<span class="breadcrumb-item active">Home</span>';
        return;
    }
    const parts = filePath.split('/').filter(p => p && p !== 'README.md');
    let html = '<span class="breadcrumb-item">Home</span>';
    parts.forEach((p, i) => {
        const label = p.replace(/\.md$/i, '').replace(/\.html$/i, '');
        const isLast = i === parts.length - 1;
        html += `<span class="breadcrumb-sep">/</span>`;
        html += `<span class="breadcrumb-item${isLast ? ' active' : ''}">${label}</span>`;
    });
    bc.innerHTML = html;
}

/* ─────────────────────────────────────────
   WELCOME SCREEN
───────────────────────────────────────── */
function showWelcome() {
    currentFile = null;
    setBreadcrumb(null);
    document.getElementById('backBtn').style.display = 'none';

    const p = (path) => BASE_PATH ? `${BASE_PATH}/${path}` : path;

    document.getElementById('content').innerHTML = `
        <div class="welcome">
            ${IS_FILE ? `<div class="notice">
                <strong>Running from file system.</strong> Browsers block local file loading.
                Start a local server: <code>npx serve</code> → <code>http://localhost:3000</code>
                or <code>python -m http.server</code> → <code>http://localhost:8000</code>
            </div>` : ''}

            <div class="welcome-hero">
                <div class="welcome-badge">Active & updated</div>
                <h1 class="welcome-title">
                    Land your next<br><span class="hl">engineering role</span>
                </h1>
                <p class="welcome-sub">
                    A curated knowledge base covering system design, algorithms,
                    architecture, and company-specific prep — all in one place.
                </p>
            </div>

            <div class="stats">
                <div class="stat">
                    <div class="stat-num">100+</div>
                    <div class="stat-lbl">Topics</div>
                </div>
                <div class="stat">
                    <div class="stat-num">500+</div>
                    <div class="stat-lbl">Questions</div>
                </div>
                <div class="stat">
                    <div class="stat-num">50+</div>
                    <div class="stat-lbl">Patterns</div>
                </div>
            </div>

            <div class="section">
                <h2 class="section-title">Quick Start</h2>
                <div class="cards">
                    <a href="#" data-file="README.md" class="card">
                        <span class="card-icon">📖</span>README
                    </a>
                    <a href="#" data-file="Resume-Career/Interview-Preparation-Cheatsheet.md" class="card">
                        <span class="card-icon">📋</span>Interview Prep Cheatsheet
                    </a>
                    <a href="#" data-file="Frameworks/Frontend/basics/js.md" class="card">
                        <span class="card-icon">📘</span>JavaScript
                    </a>
                    <a href="#" data-file="Frameworks/Frontend/basics/TypeScript.md" class="card">
                        <span class="card-icon">📗</span>TypeScript
                    </a>
                    <a href="#" data-file="System Design/System Design.md" class="card">
                        <span class="card-icon">🏗️</span>System Design
                    </a>
                    <a href="#" data-file="design/Design-Patterns/intro.md" class="card">
                        <span class="card-icon">🎨</span>Design Patterns
                    </a>
                    <a href="#" data-file="design/SOLID-Principles/SOLID Principles Complete Guide.md" class="card">
                        <span class="card-icon">🔧</span>SOLID
                    </a>
                    <a href="#" data-file="Infrastructure/Kubernetes.md" class="card">
                        <span class="card-icon">☸️</span>Kubernetes
                    </a>
                </div>
            </div>

            <div class="section">
                <h2 class="section-title">Problem Solving & Code</h2>
                <p class="welcome-sub" style="margin-bottom:1rem;font-size:.875rem">Open from the sidebar: <strong>Problem Solving</strong> → Overview, LeetCode solutions (.rb), Data Structures, HackerRank. Click any file to view code in-app.</p>
                <div class="cards">
                    <a href="#" data-file="Problem Solving/Readme.md" class="card">
                        <span class="card-icon">📋</span>Problem Solving Overview
                    </a>
                    <a href="${p('Problem Solving/75leetcode.html')}" target="_blank" rel="noopener" class="card">
                        <span class="card-icon">📋</span>75 LeetCode (HTML)
                    </a>
                    <a href="${p('Problem Solving/patterns.html')}" target="_blank" rel="noopener" class="card">
                        <span class="card-icon">🧩</span>Patterns (HTML)
                    </a>
                </div>
            </div>

            <div class="section">
                <h2 class="section-title">Playgrounds</h2>
                <p class="welcome-sub" style="margin-bottom:1rem;font-size:.875rem">Interactive prep (same design as Node.js). Open in new tab.</p>
                <div class="cards">
                    <a href="${p('Frameworks/Backend/node/nodejs-interview-prep.html')}" target="_blank" rel="noopener" class="card">
                        <span class="card-icon">🟢</span>Node.js
                    </a>
                    <a href="${p('Frameworks/Backend/Rails/ruby-rails-interview-prep.html')}" target="_blank" rel="noopener" class="card">
                        <span class="card-icon">💎</span>Ruby & Rails
                    </a>
                    <a href="${p('Frameworks/Backend/dotNet/dotnet-interview-prep.html')}" target="_blank" rel="noopener" class="card">
                        <span class="card-icon">🟣</span>C# & .NET
                    </a>
                    <a href="${p('specialized/LLM/ai-engineering-interview-prep.html')}" target="_blank" rel="noopener" class="card">
                        <span class="card-icon">🤖</span>AI Engineering
                    </a>
                    <a href="${p('Databases/database-interview-prep.html')}" target="_blank" rel="noopener" class="card">
                        <span class="card-icon">🗄️</span>Database
                    </a>
                    <a href="${p('Frameworks/Frontend/basics/html-interview-prep.html')}" target="_blank" rel="noopener" class="card">
                        <span class="card-icon">📄</span>HTML
                    </a>
                    <a href="${p('System Design/system-design-interview-prep.html')}" target="_blank" rel="noopener" class="card">
                        <span class="card-icon">🏗️</span>System Design
                    </a>
                    <a href="${p('DevOps/devops-infrastructure-interview-prep.html')}" target="_blank" rel="noopener" class="card">
                        <span class="card-icon">🔄</span>DevOps
                    </a>
                    <a href="${p('design/design-interview-prep.html')}" target="_blank" rel="noopener" class="card">
                        <span class="card-icon">🔧</span>Design & OOD
                    </a>
                    <a href="${p('Resume-Career/behavioral-leadership-interview-prep.html')}" target="_blank" rel="noopener" class="card">
                        <span class="card-icon">⭐</span>Behavioral
                    </a>
                </div>
            </div>
        </div>
    `;

    // Bind quick-link cards
    document.querySelectorAll('.card[data-file]').forEach(el => {
        el.addEventListener('click', (e) => {
            e.preventDefault();
            loadFile(el.getAttribute('data-file'));
        });
    });
}

/* ─────────────────────────────────────────
   FILE LOADER
───────────────────────────────────────── */
async function loadFile(filePath, addToHistory = true) {
    if (!filePath) return;

    if (IS_FILE) {
        showFileError(filePath);
        return;
    }

    currentFile = filePath;
    setBreadcrumb(filePath);

    const backBtn = document.getElementById('backBtn');
    if (addToHistory) {
        navHistory.push(filePath);
        backBtn.style.display = navHistory.length > 1 ? 'flex' : 'none';
    } else {
        backBtn.style.display = navHistory.length > 1 ? 'flex' : 'none';
    }

    // Loading state
    document.getElementById('content').innerHTML = `
        <div class="state">
            <div class="spinner"></div>
            <p>Loading file…</p>
        </div>
    `;

    // Update URL hash
    try {
        const hash = encodeURIComponent(filePath);
        const url = BASE_PATH ? `${BASE_PATH}/#${hash}` : `/#${hash}`;
        window.history.pushState({ file: filePath }, '', url);
    } catch (e) { /* ignore */ }

    try {
        let fullPath = BASE_PATH ? `${BASE_PATH}/${filePath.replace(/^\//, '')}` : filePath;
        let resp = await fetch(fullPath);

        if (!resp.ok && BASE_PATH) {
            resp = await fetch(filePath);
        }

        if (!resp.ok) throw new Error(`${resp.status} ${resp.statusText}`);

        const text = await resp.text();

        if (CODE_EXTENSIONS.test(filePath)) {
            renderCodeFile(text, filePath, addToHistory);
        } else {
            renderMarkdown(text, filePath, addToHistory);
        }

    } catch (err) {
        document.getElementById('content').innerHTML = `
            <div class="state">
                <div class="state-icon">⚠️</div>
                <h2>Could not load file</h2>
                <p>${filePath}<br><small style="color:var(--text-3)">${err.message}</small></p>
                <button class="btn" onclick="showWelcome()">← Go Home</button>
            </div>
        `;
    }
}

/* ─────────────────────────────────────────
   MARKDOWN RENDERER
───────────────────────────────────────── */
function renderMarkdown(markdown, filePath, addToHistory) {
    marked.setOptions({ breaks: true, gfm: true, mangle: false, headerIds: true });
    const html = marked.parse(markdown);

    document.getElementById('content').innerHTML = `
        <div class="md-wrap">
            <article class="md">${html}</article>
        </div>
    `;

    // Scroll to top
    document.getElementById('content').scrollTop = 0;

    // Activate sidebar item
    setActiveFile(filePath);

    // Fix internal markdown links
    fixInternalLinks(filePath);
}

function renderCodeFile(code, filePath, addToHistory) {
    const ext = filePath.split('.').pop().toLowerCase();
    const langMap = { rb: 'ruby', js: 'javascript', ts: 'typescript', py: 'python', java: 'java', cpp: 'cpp', c: 'c', go: 'go', rs: 'rust', kt: 'kotlin', scala: 'scala' };
    const lang = langMap[ext] || ext;
    const label = filePath.split('/').pop();
    const escaped = escapeHtml(code);

    document.getElementById('content').innerHTML = `
        <div class="md-wrap">
            <div class="code-file-header">
                <span class="code-file-label">${escapeHtml(label)}</span>
                <span class="code-file-lang">${lang}</span>
            </div>
            <pre class="code-file-pre"><code class="language-${lang}">${escaped}</code></pre>
        </div>
    `;

    document.getElementById('content').scrollTop = 0;
    setActiveFile(filePath);
}

function escapeHtml(str) {
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
}

function fixInternalLinks(currentPath) {
    document.querySelectorAll('.md a').forEach(link => {
        const href = link.getAttribute('href');
        if (!href || href.startsWith('http') || href.startsWith('mailto:')) return;

        if (href.endsWith('.md') || href.includes('.md#')) {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                const filePart = href.split('#')[0];
                const resolved = resolvePath(filePart, currentPath);
                if (resolved) {
                    loadFile(resolved);
                    if (href.includes('#')) {
                        const id = href.split('#')[1];
                        setTimeout(() => {
                            const el = document.getElementById(id) || document.querySelector(`[id="${id}"]`);
                            if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
                        }, 300);
                    }
                }
            });
            link.classList.add('internal-link');
        }
    });
}

function resolvePath(href, currentPath) {
    if (!href) return null;
    let h = href;
    if (BASE_PATH && h.startsWith(BASE_PATH)) h = h.slice(BASE_PATH.length);
    if (h.startsWith('/')) h = h.slice(1);
    if (!h.startsWith('..') && !h.startsWith('.') && h.includes('/')) return h;
    if (!currentPath) return h;
    const currentDir = currentPath.slice(0, currentPath.lastIndexOf('/'));
    const parts = currentDir ? currentDir.split('/').filter(Boolean) : [];
    h.split('/').filter(Boolean).forEach(p => {
        if (p === '..') parts.pop();
        else if (p !== '.') parts.push(p);
    });
    return parts.join('/');
}

/* ─────────────────────────────────────────
   FILE PROTOCOL ERROR
───────────────────────────────────────── */
function showFileError(file) {
    setBreadcrumb(null);
    document.getElementById('content').innerHTML = `
        <div class="state">
            <div class="state-icon">🔒</div>
            <h2>Local server required</h2>
            <p>
                This app was opened via <code style="font-size:.8em;color:var(--accent)">file://</code>.
                Browsers block local file loading for security.<br><br>
                Run a local server in the project folder:
            </p>
            <div class="notice" style="text-align:left;max-width:400px">
                <code>npx serve</code> → open <code>http://localhost:3000</code><br>
                or<br>
                <code>python -m http.server</code> → open <code>http://localhost:8000</code>
            </div>
            <button class="btn" onclick="showWelcome()">← Back</button>
        </div>
    `;
}

/* ─────────────────────────────────────────
   GLOBAL EXPORTS
───────────────────────────────────────── */
window.showWelcome = showWelcome;
