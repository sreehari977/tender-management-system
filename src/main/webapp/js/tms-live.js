/**
 * Tender Management System (TMS) — Live Interactive Client Engine
 * Provides live countdown timers, number ticker counters, instant table filtering,
 * toast notification system, one-click copy, and page transitions.
 */

(function(window, document) {
    'use strict';

    var TMS = window.TMS = window.TMS || {};

    // 1. Toast Notification System
    TMS.toast = function(type, message, duration) {
        duration = duration || 3200;
        var container = document.getElementById('tmsToastContainer');
        if (!container) {
            container = document.createElement('div');
            container.id = 'tmsToastContainer';
            container.className = 'tms-toast-container';
            document.body.appendChild(container);
        }

        var toast = document.createElement('div');
        toast.className = 'tms-toast tms-toast-' + (type || 'info');
        
        var icon = '&#9432;';
        if (type === 'success') icon = '&#10003;';
        if (type === 'warning') icon = '&#9888;';
        if (type === 'danger' || type === 'error') icon = '&#10005;';

        toast.innerHTML = '<span class=tms-toast-icon>' + icon + '</span>' +
                          '<div class=tms-toast-msg>' + message + '</div>' +
                          '<button type=button class=tms-toast-close aria-label=Close>&times;</button>';

        container.appendChild(toast);

        // Slide in
        requestAnimationFrame(function() {
            toast.classList.add('show');
        });

        function dismiss() {
            toast.classList.remove('show');
            setTimeout(function() {
                if (toast.parentNode) {
                    toast.parentNode.removeChild(toast);
                }
            }, 250);
        }

        toast.querySelector('.tms-toast-close').addEventListener('click', dismiss);
        setTimeout(dismiss, duration);
    };

    // 2. Clipboard Copy Helper
    TMS.copy = function(text, label) {
        if (!text) return;
        if (navigator.clipboard && navigator.clipboard.writeText) {
            navigator.clipboard.writeText(text).then(function() {
                TMS.toast('success', (label ? label + ': ' : '') + 'Copied to clipboard!');
            }).catch(function() {
                fallbackCopy(text, label);
            });
        } else {
            fallbackCopy(text, label);
        }
    };

    function fallbackCopy(text, label) {
        var ta = document.createElement('textarea');
        ta.value = text;
        ta.style.position = 'fixed';
        ta.style.opacity = '0';
        document.body.appendChild(ta);
        ta.select();
        try {
            document.execCommand('copy');
            TMS.toast('success', (label ? label + ': ' : '') + 'Copied to clipboard!');
        } catch (e) {
            TMS.toast('warning', 'Could not copy automatically. Please copy manually.');
        }
        document.body.removeChild(ta);
    }

    // 3. Scroll Reading Progress Bar
    TMS.initScrollProgress = function() {
        var bar = document.getElementById('tmsScrollProgressBar');
        if (!bar) {
            bar = document.createElement('div');
            bar.id = 'tmsScrollProgressBar';
            document.body.appendChild(bar);
        }

        window.addEventListener('scroll', function() {
            var docElem = document.documentElement;
            var docBody = document.body;
            var scrollTop = docElem.scrollTop || docBody.scrollTop;
            var scrollHeight = (docElem.scrollHeight || docBody.scrollHeight) - docElem.clientHeight;
            var progress = scrollHeight > 0 ? (scrollTop / scrollHeight) * 100 : 0;
            bar.style.width = Math.min(100, Math.max(0, progress)) + '%';
        }, { passive: true });
    };

    // 4. Animated Number Counters (for Dashboard KPIs)
    TMS.initNumberCounters = function() {
        var counters = document.querySelectorAll('.counter-value, [data-counter]');
        counters.forEach(function(el) {
            var targetText = el.getAttribute('data-counter') || el.textContent.trim();
            var isCurrency = targetText.indexOf('₹') !== -1 || el.classList.contains('counter-currency');
            var cleanNum = parseFloat(targetText.replace(/[^0-9.]/g, ''));

            if (isNaN(cleanNum)) return;

            var duration = 1200;
            var start = 0;
            var startTime = null;

            function format(num) {
                var rounded = Math.round(num);
                var formatted = rounded.toLocaleString('en-IN');
                return isCurrency ? '₹ ' + formatted : formatted;
            }

            function step(timestamp) {
                if (!startTime) startTime = timestamp;
                var progress = Math.min((timestamp - startTime) / duration, 1);
                // Ease-out cubic
                var ease = 1 - Math.pow(1 - progress, 3);
                var current = start + (cleanNum - start) * ease;
                el.textContent = format(current);
                if (progress < 1) {
                    requestAnimationFrame(step);
                } else {
                    el.textContent = format(cleanNum);
                }
            }

            requestAnimationFrame(step);
        });
    };

    // 5. Live Countdown Timers for Deadlines
    TMS.initCountdowns = function() {
        var countdownEls = document.querySelectorAll('[data-deadline]');
        if (!countdownEls.length) return;

        function updateAll() {
            var now = new Date().getTime();

            countdownEls.forEach(function(el) {
                var deadlineStr = el.getAttribute('data-deadline');
                if (!deadlineStr) return;

                var deadlineTime = new Date(deadlineStr).getTime();
                if (isNaN(deadlineTime)) return;

                var diff = deadlineTime - now;

                if (diff <= 0) {
                    el.innerHTML = '<span class=badge bg-danger>Deadline Passed</span>';
                    el.classList.add('text-danger');
                    return;
                }

                var days = Math.floor(diff / (1000 * 60 * 60 * 24));
                var hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                var mins = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
                var secs = Math.floor((diff % (1000 * 60)) / 1000);

                var badgeClass = 'bg-primary-subtle text-primary border border-primary-subtle';
                var pulseClass = '';

                if (days === 0 && hours < 24) {
                    badgeClass = 'bg-danger-subtle text-danger border border-danger-subtle';
                    pulseClass = 'tms-pulse';
                } else if (days <= 3) {
                    badgeClass = 'bg-warning-subtle text-warning border border-warning-subtle';
                }

                var displayStr = '';
                if (days > 0) displayStr += days + 'd ';
                displayStr += (hours < 10 ? '0' : '') + hours + 'h ';
                displayStr += (mins < 10 ? '0' : '') + mins + 'm ';
                displayStr += (secs < 10 ? '0' : '') + secs + 's';

                el.innerHTML = '<span class=badge ' + badgeClass + ' ' + pulseClass + ' px-2 py-1 font-monospace style=letter-spacing: 0.5px;>' +
                               '&#9203; ' + displayStr + ' left</span>';
            });
        }

        updateAll();
        setInterval(updateAll, 1000);
    };

    // 6. Live In-Page Table Filter
    TMS.initLiveTableFilter = function() {
        var filterInputs = document.querySelectorAll('[data-table-filter]');
        filterInputs.forEach(function(input) {
            var targetSelector = input.getAttribute('data-table-filter');
            var table = document.querySelector(targetSelector);
            if (!table) return;

            var tbody = table.querySelector('tbody') || table;
            var countBadge = document.querySelector(input.getAttribute('data-filter-count'));

            input.addEventListener('input', function() {
                var query = this.value.toLowerCase().trim();
                var rows = tbody.querySelectorAll('tr');
                var visibleCount = 0;

                rows.forEach(function(row) {
                    if (row.classList.contains('tms-no-filter')) return;
                    var text = row.textContent.toLowerCase();
                    if (!query || text.indexOf(query) !== -1) {
                        row.style.display = '';
                        visibleCount++;
                    } else {
                        row.style.display = 'none';
                    }
                });

                if (countBadge) {
                    countBadge.textContent = visibleCount + ' matches';
                }
            });
        });
    };

    // 7. Interactive One-Click Copy Elements
    TMS.initCopyButtons = function() {
        document.addEventListener('click', function(e) {
            var target = e.target.closest('[data-copy]');
            if (!target) return;
            var text = target.getAttribute('data-copy');
            var label = target.getAttribute('data-copy-label') || 'Item';
            TMS.copy(text, label);
        });
    };

    // 8. Auto-initialize on DOM ready
    document.addEventListener('DOMContentLoaded', function() {
        TMS.initScrollProgress();
        TMS.initNumberCounters();
        TMS.initCountdowns();
        TMS.initLiveTableFilter();
        TMS.initCopyButtons();
    });

})(window, document);
