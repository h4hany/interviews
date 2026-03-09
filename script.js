// GitHub Pages base path detection
const getBasePath = () => {
    // If running on GitHub Pages, detect the repository name from pathname
    const pathname = window.location.pathname;
    
    // Remove leading and trailing slashes, then split
    const parts = pathname.replace(/^\/|\/$/g, '').split('/');
    
    // If we have parts and the first part is not empty and not 'index.html'
    if (parts.length > 0 && parts[0] && parts[0] !== 'index.html') {
        // Check if we're on GitHub Pages (has a repo name)
        // For localhost, pathname might be just '/' or '/index.html'
        if (window.location.hostname !== 'localhost' && window.location.hostname !== '127.0.0.1') {
            return `/${parts[0]}`;
        }
    }
    
    // For local development, try to detect from pathname
    // If pathname has more than just '/' or '/index.html', it might be a subdirectory
    if (pathname !== '/' && pathname !== '/index.html' && pathname.includes('/')) {
        const match = pathname.match(/^\/([^\/]+)/);
        if (match && match[1] && match[1] !== 'index.html') {
            return `/${match[1]}`;
        }
    }
    
    return '';
};

const BASE_PATH = getBasePath();
console.log('Base path detected:', BASE_PATH || '(root)');

// File structure based on README.md
const fileStructure = {
    "README.md": "README.md",
    "Frontend": {
        "JavaScript": "Frameworks/Frontend/basics/js.md",
        "TypeScript": "Frameworks/Frontend/basics/TypeScript.md",
        "HTML": "Frameworks/Frontend/basics/html.md",
        "CSS": "Frameworks/Frontend/basics/css.md",
        "React": "Frameworks/Frontend/React/React.md",
        "Angular": "Frameworks/Frontend/Angular/Angular.md"
    },
    "Backend": {
        "Ruby": "Programming/Ruby.md",
        "Go": "Programming/Go.md",
        ".NET/C#": "Programming/dotNet.md",
        "Ruby on Rails": "Frameworks/Backend/Rails/Ruby on Rails.md",
        "Node.js": "Frameworks/Backend/Node.md"
    },
    "Databases": {
        "MySQL": "Databases/mysql.md",
        "PostgreSQL": "Databases/postgresql.md",
        "MongoDB": "Databases/mongodb.md"
    },
    "Design Principles": {
        "SOLID Principles": "Solid Princables/SOLID Principles Complete Guide.md",
        "Design Patterns": {
            "Introduction": "Design Patterns/intro.md",
            "Quick Reference": "Design Patterns/Quick Reference Guide.md",
            "Creational": {
                "Singleton": "Design Patterns/Creational/Singleton.md",
                "Factory": "Design Patterns/Creational/Factory.md",
                "Abstract Factory": "Design Patterns/Creational/Abstract Factory.md",
                "Builder": "Design Patterns/Creational/Builder.md",
                "Prototype": "Design Patterns/Creational/Prototype.md"
            },
            "Structural": {
                "Adapter": "Design Patterns/Structural/Adapter.md",
                "Bridge": "Design Patterns/Structural/Bridge.md",
                "Composite": "Design Patterns/Structural/Composite.md",
                "Decorator": "Design Patterns/Structural/Decorator.md",
                "Facade": "Design Patterns/Structural/Facade.md",
                "Flyweight": "Design Patterns/Structural/Flyweight.md",
                "Proxy": "Design Patterns/Structural/Proxy.md"
            },
            "Behavioral": {
                "Chain of Responsibility": "Design Patterns/Behavioral/Chain of Responsibility.md",
                "Command": "Design Patterns/Behavioral/Command.md",
                "Interpreter": "Design Patterns/Behavioral/Interpreter.md",
                "Iterator": "Design Patterns/Behavioral/Iterator.md",
                "Mediator": "Design Patterns/Behavioral/Mediator.md",
                "Memento": "Design Patterns/Behavioral/Memento.md",
                "Observer": "Design Patterns/Behavioral/Observer.md",
                "State": "Design Patterns/Behavioral/State.md",
                "Strategy": "Design Patterns/Behavioral/Strategy.md",
                "Template Method": "Design Patterns/Behavioral/Template Method.md",
                "Visitor": "Design Patterns/Behavioral/Visitor.md"
            }
        }
    },
    "Object-Oriented Design": {
        "OOD Concepts": "Object Orianted Design/OOD.md",
        "Delivery System OOD": "Object Orianted Design/Delivery System OOD.md"
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
        "Redis": "Caching/Redis.md",
        "RabbitMQ": "Messaging/RabbitMQ.md",
        "Kafka": "Messaging/Kafka.md"
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
        "Other": {
            "Lucidya": "Companies/Lucidya Backend Team Lead Interview Preparation Guide.md",
            "Sanofi": "Companies/Sanofi/interview_questions.md"
        }
    },
    "Specialized Topics": {
        "Senior AI Engineer": "LLM/Senior AI Engineer Interview.md",
        "Free LLM Resources": "LLM/FreeLLM.md"
    }
};

let currentFile = null;
let history = [];

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    initializeApp();
});

function initializeApp() {
    renderFileTree();
    setupEventListeners();
    loadTheme();
    
    // Load file from hash or default to README
    if (window.location.hash) {
        const file = decodeURIComponent(window.location.hash.substring(1));
        loadFile(file, false);
    } else {
        showWelcomeScreen();
    }
}

function setupEventListeners() {
    // Toggle sidebar (desktop)
    const toggleSidebar = document.getElementById('toggleSidebar');
    if (toggleSidebar) {
        toggleSidebar.addEventListener('click', () => {
            document.querySelector('.sidebar').classList.toggle('open');
        });
    }

    // Mobile menu button
    const mobileMenuBtn = document.getElementById('mobileMenuBtn');
    if (mobileMenuBtn) {
        mobileMenuBtn.addEventListener('click', () => {
            const sidebar = document.querySelector('.sidebar');
            const overlay = document.getElementById('sidebarOverlay');
            sidebar.classList.add('open');
            overlay.classList.add('active');
        });
    }

    // Sidebar overlay (mobile)
    const overlay = document.getElementById('sidebarOverlay');
    if (overlay) {
        overlay.addEventListener('click', () => {
            const sidebar = document.querySelector('.sidebar');
            sidebar.classList.remove('open');
            overlay.classList.remove('active');
        });
    }

    // Search
    const searchInput = document.getElementById('searchInput');
    const clearSearch = document.getElementById('clearSearch');
    
    if (searchInput) {
        searchInput.addEventListener('input', (e) => {
            const value = e.target.value;
            filterFileTree(value);
            clearSearch.style.display = value ? 'flex' : 'none';
        });
    }

    if (clearSearch) {
        clearSearch.addEventListener('click', () => {
            searchInput.value = '';
            filterFileTree('');
            clearSearch.style.display = 'none';
            searchInput.focus();
        });
    }

    // Back button
    const backBtn = document.getElementById('backBtn');
    if (backBtn) {
        backBtn.addEventListener('click', () => {
            if (history.length > 1) {
                history.pop(); // Remove current
                const previous = history.pop();
                loadFile(previous, false);
            }
        });
    }

    // Dark mode toggle
    const toggleDarkModeBtn = document.getElementById('toggleDarkMode');
    if (toggleDarkModeBtn) {
        toggleDarkModeBtn.addEventListener('click', () => {
            toggleDarkMode();
        });
    }

    // Quick links - attach event listeners after DOM is ready
    attachQuickLinkListeners();

    // Handle browser back/forward
    window.addEventListener('popstate', (e) => {
        if (e.state && e.state.file) {
            loadFile(e.state.file, false);
        } else if (!window.location.hash) {
            showWelcomeScreen();
        }
    });
}

function renderFileTree() {
    const fileTree = document.getElementById('fileTree');
    if (!fileTree) return;
    
    fileTree.innerHTML = '';
    // Only render the structure, README.md is already in fileStructure
    fileTree.appendChild(createTreeStructure(fileStructure, 0));
}

function createTreeItem(name, path, level) {
    const item = document.createElement('div');
    item.className = 'file';
    item.setAttribute('data-path', path);
    item.style.paddingLeft = `${level * 1.5 + 1}rem`;
    item.innerHTML = `<span class="file-icon">📄</span> <span>${name}</span>`;
    item.addEventListener('click', () => {
        loadFile(path);
        // Close sidebar on mobile after selection
        if (window.innerWidth <= 768) {
            const sidebar = document.querySelector('.sidebar');
            const overlay = document.getElementById('sidebarOverlay');
            sidebar.classList.remove('open');
            overlay.classList.remove('active');
        }
    });
    return item;
}

function createTreeStructure(structure, level = 0) {
    const container = document.createElement('div');
    
    Object.keys(structure).forEach(key => {
        const value = structure[key];
        
        if (typeof value === 'string') {
            // It's a file
            container.appendChild(createTreeItem(key, value, level));
        } else {
            // It's a folder
            const folder = document.createElement('div');
            folder.className = 'folder';
            
            const folderHeader = document.createElement('div');
            folderHeader.className = 'folder-header';
            folderHeader.innerHTML = `<span class="folder-icon">▶</span> <span>${key}</span>`;
            folderHeader.addEventListener('click', (e) => {
                e.stopPropagation();
                const content = folder.querySelector('.folder-content');
                if (content) {
                    content.classList.toggle('expanded');
                    folder.classList.toggle('active');
                }
            });
            folder.appendChild(folderHeader);
            
            const folderContent = document.createElement('div');
            folderContent.className = 'folder-content';
            folderContent.appendChild(createTreeStructure(value, level + 1));
            folder.appendChild(folderContent);
            
            container.appendChild(folder);
        }
    });
    
    return container;
}

function filterFileTree(searchTerm) {
    const items = document.querySelectorAll('.file, .folder');
    const term = searchTerm.toLowerCase();
    
    if (!term) {
        items.forEach(item => {
            item.style.display = '';
        });
        return;
    }
    
    items.forEach(item => {
        const text = item.textContent.toLowerCase();
        if (text.includes(term)) {
            item.style.display = '';
            // Expand parent folders
            let parent = item.parentElement;
            while (parent && parent.classList.contains('folder-content')) {
                parent.classList.add('expanded');
                const folder = parent.previousElementSibling;
                if (folder) {
                    const folderElement = folder.closest('.folder');
                    if (folderElement) {
                        folderElement.classList.add('active');
                    }
                }
                parent = parent.parentElement;
            }
        } else {
            item.style.display = 'none';
        }
    });
}

function showWelcomeScreen() {
    const contentBody = document.getElementById('contentBody');
    const backBtn = document.getElementById('backBtn');
    const breadcrumb = document.getElementById('breadcrumb');
    
    if (!contentBody || !breadcrumb) {
        console.error('Required DOM elements not found');
        return;
    }
    
    currentFile = null;
    if (backBtn) backBtn.style.display = 'none';
    breadcrumb.innerHTML = '<span class="breadcrumb-item active">Home</span>';
    
    contentBody.innerHTML = `
        <div class="welcome-screen">
            <div class="welcome-content">
                <div class="welcome-icon">🚀</div>
                <h1>Welcome to Interview Prep</h1>
                <p class="welcome-subtitle">Your comprehensive guide to technical interview preparation</p>
                
                <div class="quick-stats">
                    <div class="stat-card">
                        <div class="stat-number">100+</div>
                        <div class="stat-label">Topics Covered</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">500+</div>
                        <div class="stat-label">Interview Questions</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">50+</div>
                        <div class="stat-label">Design Patterns</div>
                    </div>
                </div>

                <div class="quick-links">
                    <h3>Quick Start</h3>
                    <div class="link-grid">
                        <a href="#" data-file="README.md" class="quick-link-card">
                            <span class="link-icon">📖</span>
                            <span class="link-text">README</span>
                        </a>
                        <a href="#" data-file="Frameworks/Frontend/basics/js.md" class="quick-link-card">
                            <span class="link-icon">📘</span>
                            <span class="link-text">JavaScript</span>
                        </a>
                        <a href="#" data-file="Frameworks/Frontend/basics/TypeScript.md" class="quick-link-card">
                            <span class="link-icon">📗</span>
                            <span class="link-text">TypeScript</span>
                        </a>
                        <a href="#" data-file="System Design/System Design.md" class="quick-link-card">
                            <span class="link-icon">🏗️</span>
                            <span class="link-text">System Design</span>
                        </a>
                        <a href="#" data-file="Design Patterns/intro.md" class="quick-link-card">
                            <span class="link-icon">🎨</span>
                            <span class="link-text">Design Patterns</span>
                        </a>
                        <a href="#" data-file="Solid Princables/SOLID Principles Complete Guide.md" class="quick-link-card">
                            <span class="link-icon">🔧</span>
                            <span class="link-text">SOLID Principles</span>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    `;
    
    // Re-attach event listeners for quick links
    attachQuickLinkListeners();
}

async function loadFile(filePath, addToHistory = true) {
    if (!filePath) return;
    
    currentFile = filePath;
    const contentBody = document.getElementById('contentBody');
    const backBtn = document.getElementById('backBtn');
    const breadcrumb = document.getElementById('breadcrumb');
    
    if (!contentBody || !breadcrumb) {
        console.error('Required DOM elements not found');
        return;
    }
    
    // Update breadcrumb
    const fileName = filePath.split('/').pop().replace('.md', '');
    
    // Update breadcrumb
    const pathParts = filePath.split('/').filter(p => p && p !== 'README.md');
    let breadcrumbHTML = '<span class="breadcrumb-item active">Home</span>';
    if (pathParts.length > 0) {
        breadcrumbHTML += '<span class="breadcrumb-separator">/</span>';
        pathParts.forEach((part, index) => {
            const isLast = index === pathParts.length - 1;
            const displayName = part.replace('.md', '').replace(/\s+/g, ' ');
            if (isLast) {
                breadcrumbHTML += `<span class="breadcrumb-item active">${displayName}</span>`;
            } else {
                breadcrumbHTML += `<span class="breadcrumb-item">${displayName}</span><span class="breadcrumb-separator">/</span>`;
            }
        });
    }
    breadcrumb.innerHTML = breadcrumbHTML;
    
    // Show back button if we have history
    if (backBtn) {
        backBtn.style.display = history.length > 0 ? 'flex' : 'none';
    }
    
    // Show loading
    contentBody.innerHTML = '<div class="loading">Loading</div>';
    
    // Update URL
    const hash = encodeURIComponent(filePath);
    const url = BASE_PATH ? `${BASE_PATH}/#${hash}` : `/#${hash}`;
    try {
        window.history.pushState({ file: filePath }, '', url);
    } catch (e) {
        console.warn('Could not update URL:', e);
    }
    
    try {
        // Construct full path with base path for GitHub Pages
        let fullPath;
        if (BASE_PATH) {
            // Remove leading slash from filePath if present, then join
            const cleanPath = filePath.startsWith('/') ? filePath.substring(1) : filePath;
            fullPath = `${BASE_PATH}/${cleanPath}`;
        } else {
            fullPath = filePath;
        }
        
        console.log('Loading file:', fullPath);
        const response = await fetch(fullPath);
        
        if (!response.ok) {
            // Try without base path as fallback
            if (BASE_PATH) {
                console.log('Trying fallback path:', filePath);
                const fallbackResponse = await fetch(filePath);
                if (fallbackResponse.ok) {
                    const markdown = await fallbackResponse.text();
                    processMarkdown(markdown, filePath, addToHistory);
                    return;
                }
            }
            throw new Error(`Failed to load file: ${response.status} ${response.statusText}`);
        }
        
        const markdown = await response.text();
        processMarkdown(markdown, filePath, addToHistory);
        
    } catch (error) {
        console.error('Error loading file:', error);
        contentBody.innerHTML = `
            <div class="error">
                <h2>Error Loading File</h2>
                <p>Could not load: ${filePath}</p>
                <p style="color: var(--text-secondary); margin-top: 1rem;">${error.message}</p>
                <button class="btn" onclick="showWelcomeScreen()" style="margin-top: 1.5rem; padding: 0.75rem 1.5rem; background: var(--accent-color); color: white; border: none; border-radius: var(--radius); cursor: pointer;">Go Home</button>
            </div>
        `;
    }
}

function fixMarkdownLinks() {
    // Fix all markdown links (both .md files and relative links)
    const links = document.querySelectorAll('.markdown-content a');
    links.forEach(link => {
        const href = link.getAttribute('href');
        if (!href) return;
        
        // Skip external links
        if (href.startsWith('http://') || href.startsWith('https://') || href.startsWith('mailto:')) {
            return;
        }
        
        // Handle markdown file links
        if (href.endsWith('.md') || href.includes('.md#')) {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                // Extract file path (remove hash if present)
                const filePath = href.split('#')[0];
                const resolvedPath = resolvePath(filePath, currentFile);
                if (resolvedPath) {
                    loadFile(resolvedPath);
                    // If there's a hash, scroll to the section after loading
                    if (href.includes('#')) {
                        const sectionId = href.split('#')[1];
                        setTimeout(() => {
                            const element = document.getElementById(sectionId) || 
                                          document.querySelector(`[id="${sectionId}"]`) ||
                                          document.querySelector(`a[name="${sectionId}"]`);
                            if (element) {
                                element.scrollIntoView({ behavior: 'smooth', block: 'start' });
                            }
                        }, 300);
                    }
                }
            });
            link.style.cursor = 'pointer';
            link.classList.add('internal-link');
        }
    });
}

function resolvePath(href, currentPath) {
    if (!href) return null;
    
    // Remove any base path from href
    let cleanHref = href;
    if (BASE_PATH && cleanHref.startsWith(BASE_PATH)) {
        cleanHref = cleanHref.substring(BASE_PATH.length);
    }
    
    // Remove leading slash
    if (cleanHref.startsWith('/')) {
        cleanHref = cleanHref.substring(1);
    }
    
    // If it's already an absolute path (starts with a known directory), return it
    if (cleanHref.includes('/') && !cleanHref.startsWith('..') && !cleanHref.startsWith('.')) {
        return cleanHref;
    }
    
    // If no current path, return the cleaned href
    if (!currentPath) return cleanHref;
    
    // Resolve relative paths
    const currentDir = currentPath.substring(0, currentPath.lastIndexOf('/'));
    const parts = currentDir ? currentDir.split('/').filter(p => p) : [];
    const hrefParts = cleanHref.split('/').filter(p => p);
    
    hrefParts.forEach(part => {
        if (part === '..') {
            parts.pop();
        } else if (part !== '.') {
            parts.push(part);
        }
    });
    
    return parts.length > 0 ? parts.join('/') : cleanHref;
}

function updateActiveFile(filePath) {
    // Remove all active classes
    document.querySelectorAll('.file.active, .folder.active').forEach(item => {
        item.classList.remove('active');
    });
    
    // Find and activate the file
    const items = document.querySelectorAll('.file');
    items.forEach(item => {
        const path = item.getAttribute('data-path');
        if (path === filePath) {
            item.classList.add('active');
            // Expand parent folders
            let parent = item.parentElement;
            while (parent && parent.classList.contains('folder-content')) {
                parent.classList.add('expanded');
                const folder = parent.previousElementSibling;
                if (folder) {
                    const folderElement = folder.closest('.folder');
                    if (folderElement) {
                        folderElement.classList.add('active');
                    }
                }
                parent = parent.parentElement;
            }
            // Scroll into view
            item.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }
    });
}

function toggleDarkMode() {
    const currentTheme = document.documentElement.getAttribute('data-theme');
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);
}

function loadTheme() {
    const savedTheme = localStorage.getItem('theme') || 'light';
    document.documentElement.setAttribute('data-theme', savedTheme);
}

// Handle hash changes
window.addEventListener('hashchange', () => {
    const file = window.location.hash.substring(1);
    if (file) {
        loadFile(decodeURIComponent(file), false);
    } else {
        showWelcomeScreen();
    }
});

function processMarkdown(markdown, filePath, addToHistory) {
    const contentBody = document.getElementById('contentBody');
    
    // Configure marked options
    marked.setOptions({
        breaks: true,
        gfm: true,
        headerIds: true,
        mangle: false
    });
    
    const html = marked.parse(markdown);
    
    contentBody.innerHTML = `<div class="markdown-content">${html}</div>`;
    
    // Add to history
    if (addToHistory) {
        history.push(filePath);
    }
    
    // Scroll to top
    contentBody.scrollTop = 0;
    
    // Update active file in sidebar
    updateActiveFile(filePath);
    
    // Fix links in markdown to work with our system
    fixMarkdownLinks();
}

function attachQuickLinkListeners() {
    document.querySelectorAll('.quick-link-card').forEach(link => {
        // Remove existing listeners by cloning
        const newLink = link.cloneNode(true);
        link.parentNode.replaceChild(newLink, link);
        
        newLink.addEventListener('click', (e) => {
            e.preventDefault();
            const file = newLink.getAttribute('data-file');
            if (file) {
                console.log('Quick link clicked:', file);
                loadFile(file);
            }
        });
    });
}

// Make showWelcomeScreen available globally for error button
window.showWelcomeScreen = showWelcomeScreen;
