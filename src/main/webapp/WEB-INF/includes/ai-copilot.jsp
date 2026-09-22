<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!-- Floating AI Copilot Trigger Button -->
<button type="button" 
        id="aiCopilotBtn" 
        class="btn btn-gradient-ai shadow-lg rounded-pill position-fixed d-flex align-items-center gap-2 px-3 py-2" 
        style="bottom: 24px; right: 24px; z-index: 1060;" 
        data-bs-toggle="offcanvas" 
        data-bs-target="#aiCopilotOffcanvas" 
        aria-controls="aiCopilotOffcanvas"
        title="Open TMS AI Procurement Copilot & Page Guide">
    <span class="ai-sparkle-icon" style="font-size: 1.25rem;">✨</span>
    <span class="fw-bold small text-white">AI Copilot</span>
</button>

<!-- Offcanvas AI Copilot Drawer -->
<div class="offcanvas offcanvas-end shadow border-0" 
     tabindex="-1" 
     id="aiCopilotOffcanvas" 
     aria-labelledby="aiCopilotLabel" 
     style="width: 420px; max-width: 95vw; z-index: 1070;">
     
    <div class="offcanvas-header bg-dark text-white border-bottom border-secondary py-3">
        <div class="d-flex align-items-center gap-2">
            <span class="fs-4">✨</span>
            <div>
                <h6 class="offcanvas-title fw-bold mb-0 text-white" id="aiCopilotLabel">
                    TMS Procurement Copilot
                </h6>
                <small class="text-white-50" style="font-size: 0.75rem;">
                    Contextual Page Guide &amp; AI Advisory
                </small>
            </div>
        </div>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="offcanvas" aria-label="Close"></button>
    </div>

    <!-- Navigation Tabs -->
    <ul class="nav nav-tabs nav-fill bg-light px-2 pt-2 border-bottom" id="aiCopilotTabs" role="tablist">
        <li class="nav-item" role="presentation">
            <button class="nav-link active fw-semibold small py-2" id="ai-tour-tab" data-bs-toggle="tab" data-bs-target="#ai-tour-pane" type="button" role="tab">
                🧭 Page Familiarization
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link fw-semibold small py-2" id="ai-chat-tab" data-bs-toggle="tab" data-bs-target="#ai-chat-pane" type="button" role="tab">
                💬 Ask Assistant
            </button>
        </li>
    </ul>

    <div class="offcanvas-body d-flex flex-column p-0 bg-light">
        <div class="tab-content flex-grow-1 overflow-auto p-3" id="aiTabContent">
            
            <!-- Tab 1: Page Familiarization Tour -->
            <div class="tab-pane fade show active" id="ai-tour-pane" role="tabpanel">
                <div id="aiTourLoading" class="text-center py-4 text-muted">
                    <div class="spinner-border spinner-border-sm text-primary mb-2" role="status"></div>
                    <div class="small">Analyzing current page context...</div>
                </div>

                <div id="aiTourContent" class="d-none">
                    <!-- Page Banner -->
                    <div class="card border-0 bg-white shadow-sm mb-3">
                        <div class="card-body p-3">
                            <span class="badge bg-primary-subtle text-primary border border-primary-subtle mb-1" id="aiTourBadge" style="font-size: 0.7rem;">
                                ACTIVE VIEW
                            </span>
                            <h6 class="fw-bold text-dark mb-1" id="aiTourTitle"></h6>
                            <p class="text-muted small mb-0" id="aiTourOverview" style="font-size: 0.8rem; line-height: 1.4;"></p>
                        </div>
                    </div>

                    <!-- Key Capabilities Checklist -->
                    <div class="card border-0 bg-white shadow-sm mb-3">
                        <div class="card-body p-3">
                            <h6 class="fw-bold text-dark small text-uppercase mb-2" style="letter-spacing: 0.5px;">
                                ⚡ What You Can Do Here
                            </h6>
                            <ul class="list-unstyled mb-0" id="aiTourCapabilities"></ul>
                        </div>
                    </div>

                    <!-- Pro Tips Card -->
                    <div class="card border-0 bg-white shadow-sm mb-3">
                        <div class="card-body p-3">
                            <h6 class="fw-bold text-dark small text-uppercase mb-2" style="letter-spacing: 0.5px;">
                                💡 Procurement Best Practices
                            </h6>
                            <ul class="list-unstyled mb-0" id="aiTourTips"></ul>
                        </div>
                    </div>

                    <!-- Suggested Prompts -->
                    <div class="mb-2">
                        <small class="fw-bold text-secondary text-uppercase" style="font-size: 0.7rem;">Quick Questions:</small>
                        <div class="d-flex flex-wrap gap-1 mt-1" id="aiTourPrompts"></div>
                    </div>
                </div>
            </div>

            <!-- Tab 2: AI Q&A Chat -->
            <div class="tab-pane fade h-100 d-flex flex-column" id="ai-chat-pane" role="tabpanel">
                <div class="chat-messages-container flex-grow-1 overflow-auto p-2" id="aiChatMessages" style="min-height: 280px; max-height: calc(100vh - 240px);">
                    <!-- Welcome greeting -->
                    <div class="d-flex mb-3 gap-2">
                        <div class="avatar-ai bg-primary text-white rounded-circle d-flex align-items-center justify-content-center flex-shrink-0" style="width: 28px; height: 28px; font-size: 0.8rem;">✨</div>
                        <div class="p-3 bg-white rounded-3 shadow-sm text-dark small border" style="max-width: 85%;">
                            <p class="mb-1"><strong>Hello! I am your TMS Procurement Copilot.</strong></p>
                            <p class="mb-0 text-secondary" style="font-size: 0.8rem;">
                                Ask me about tender rules, L1 evaluation criteria, drafting competitive proposals, or navigating the platform.
                            </p>
                        </div>
                    </div>
                </div>

                <!-- Chat Input Box -->
                <div class="pt-2 border-top mt-auto bg-white p-3 rounded-bottom">
                    <form id="aiChatForm" class="d-flex gap-2">
                        <input type="text" 
                               id="aiChatInput" 
                               class="form-control form-control-sm" 
                               placeholder="Ask a procurement question..." 
                               autocomplete="off" 
                               required>
                        <button type="submit" class="btn btn-primary btn-sm px-3 fw-bold" id="aiChatSendBtn">
                            Send
                        </button>
                    </form>
                </div>
            </div>

        </div>
    </div>
</div>

<script>
(function() {
    // Detect Current Page Identifier from URL
    function detectPageContext() {
        var path = window.location.pathname;
        if (path.indexOf('dashboard') !== -1) return 'dashboard';
        if (path.indexOf('tenders') !== -1) return 'tenders';
        if (path.indexOf('tender-form') !== -1) return 'tender-form';
        if (path.indexOf('tender') !== -1) return 'tender-detail';
        if (path.indexOf('bid-form') !== -1 || path.indexOf('/bid') !== -1) return 'bid-form';
        if (path.indexOf('my-bids') !== -1) return 'my-bids';
        if (path.indexOf('bids') !== -1) return 'bid-comparison';
        if (path.indexOf('vendor-approvals') !== -1) return 'vendor-approvals';
        if (path.indexOf('audit-logs') !== -1) return 'audit-logs';
        return 'dashboard';
    }

    var currentPage = detectPageContext();

    // Load Contextual Page Guide when Offcanvas is shown
    var copilotOffcanvas = document.getElementById('aiCopilotOffcanvas');
    var guideLoaded = false;

    if (copilotOffcanvas) {
        copilotOffcanvas.addEventListener('show.bs.offcanvas', function () {
            if (!guideLoaded) {
                loadPageGuide();
            }
        });
    }

    function loadPageGuide() {
        var contextPath = '${pageContext.request.contextPath}';
        fetch(contextPath + '/api/ai?action=page_guide&page=' + encodeURIComponent(currentPage))
            .then(function(res) { return res.ok ? res.json() : null; })
            .then(function(data) {
                if (!data) return;
                document.getElementById('aiTourLoading').classList.add('d-none');
                var content = document.getElementById('aiTourContent');
                content.classList.remove('d-none');

                document.getElementById('aiTourTitle').textContent = data.title || 'Page Overview';
                document.getElementById('aiTourOverview').textContent = data.overview || '';

                var capList = document.getElementById('aiTourCapabilities');
                capList.innerHTML = '';
                (data.capabilities || []).forEach(function(cap) {
                    var li = document.createElement('li');
                    li.className = 'small text-secondary mb-1 d-flex align-items-start gap-2';
                    li.innerHTML = '<span class="text-success fw-bold">&bull;</span><span>' + escapeHtml(cap) + '</span>';
                    capList.appendChild(li);
                });

                var tipsList = document.getElementById('aiTourTips');
                tipsList.innerHTML = '';
                (data.tips || []).forEach(function(tip) {
                    var li = document.createElement('li');
                    li.className = 'small text-secondary mb-1 d-flex align-items-start gap-2';
                    li.innerHTML = '<span class="text-primary fw-bold">&#10003;</span><span>' + escapeHtml(tip) + '</span>';
                    tipsList.appendChild(li);
                });

                var promptBox = document.getElementById('aiTourPrompts');
                promptBox.innerHTML = '';
                (data.quickPrompts || []).forEach(function(p) {
                    var btn = document.createElement('button');
                    btn.type = 'button';
                    btn.className = 'btn btn-outline-primary btn-sm rounded-pill py-0 px-2 small';
                    btn.style.fontSize = '0.72rem';
                    btn.textContent = p;
                    btn.addEventListener('click', function() {
                        switchToChatWithPrompt(p);
                    });
                    promptBox.appendChild(btn);
                });

                guideLoaded = true;
            })
            .catch(function() {
                document.getElementById('aiTourLoading').innerHTML = '<div class="small text-danger">Guide temporarily unavailable.</div>';
            });
    }

    function switchToChatWithPrompt(text) {
        var chatTab = document.getElementById('ai-chat-tab');
        var tab = new bootstrap.Tab(chatTab);
        tab.show();
        var input = document.getElementById('aiChatInput');
        input.value = text;
        submitChatMessage(text);
    }

    // Chat Submission Handler
    var chatForm = document.getElementById('aiChatForm');
    if (chatForm) {
        chatForm.addEventListener('submit', function(e) {
            e.preventDefault();
            var input = document.getElementById('aiChatInput');
            var text = input.value.trim();
            if (!text) return;
            submitChatMessage(text);
            input.value = '';
        });
    }

    function submitChatMessage(query) {
        var container = document.getElementById('aiChatMessages');

        // Append user message
        var userMsg = document.createElement('div');
        userMsg.className = 'd-flex mb-3 justify-content-end';
        userMsg.innerHTML = '<div class="p-2 px-3 bg-primary text-white rounded-3 shadow-sm small" style="max-width: 80%;">' +
            escapeHtml(query) + '</div>';
        container.appendChild(userMsg);
        container.scrollTop = container.scrollHeight;

        // Append thinking placeholder
        var botMsg = document.createElement('div');
        botMsg.className = 'd-flex mb-3 gap-2';
        var msgId = 'botMsg_' + Date.now();
        botMsg.id = msgId;
        botMsg.innerHTML = '<div class="avatar-ai bg-primary text-white rounded-circle d-flex align-items-center justify-content-center flex-shrink-0" style="width: 28px; height: 28px; font-size: 0.8rem;">✨</div>' +
            '<div class="p-3 bg-white rounded-3 shadow-sm text-dark small border" style="max-width: 85%;">' +
            '<div class="spinner-grow spinner-grow-sm text-primary" role="status"></div> <span class="text-muted ms-1">Consulting procurement copilot...</span>' +
            '</div>';
        container.appendChild(botMsg);
        container.scrollTop = container.scrollHeight;

        var contextPath = '${pageContext.request.contextPath}';
        var formData = new URLSearchParams();
        formData.append('action', 'chat');
        formData.append('query', query);
        formData.append('page', currentPage);

        fetch(contextPath + '/api/ai', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: formData.toString()
        })
        .then(function(res) { return res.json(); })
        .then(function(data) {
            var el = document.getElementById(msgId);
            if (!el) return;
            var formatted = (data.answer || '').replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
            el.innerHTML = '<div class="avatar-ai bg-primary text-white rounded-circle d-flex align-items-center justify-content-center flex-shrink-0" style="width: 28px; height: 28px; font-size: 0.8rem;">✨</div>' +
                '<div class="p-3 bg-white rounded-3 shadow-sm text-dark small border" style="max-width: 85%;">' +
                (data.topic ? '<div class="badge bg-secondary-subtle text-secondary border mb-1" style="font-size:0.65rem;">' + escapeHtml(data.topic) + '</div>' : '') +
                '<div style="line-height: 1.45;">' + formatted + '</div>' +
                '</div>';
            container.scrollTop = container.scrollHeight;
        })
        .catch(function() {
            var el = document.getElementById(msgId);
            if (el) {
                el.innerHTML = '<div class="small text-danger p-2">Unable to fetch AI response at this moment.</div>';
            }
        });
    }

    function escapeHtml(text) {
        if (!text) return '';
        var div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
})();
</script>
