// blazorAuth.js — Google Identity Services helpers for Blazor
window.blazorAuth = (function () {
    let _dotNetRef = null;

    function initGoogle(clientId, dotNetRef) {
        _dotNetRef = dotNetRef;

        function setup() {
            if (!window.google?.accounts?.id) return;
            window.google.accounts.id.initialize({
                client_id: clientId,
                callback: function (response) {
                    const token = response?.credential ?? '';
                    if (!token) return;
                    _dotNetRef.invokeMethodAsync('OnGoogleCredential', token);
                }
            });
        }

        const SCRIPT_ID = 'google-identity-services-script';
        const existing = document.getElementById(SCRIPT_ID);
        if (existing) {
            if (window.google?.accounts?.id) setup();
            else existing.addEventListener('load', setup, { once: true });
            return;
        }

        const script = document.createElement('script');
        script.id = SCRIPT_ID;
        script.src = 'https://accounts.google.com/gsi/client';
        script.async = true;
        script.defer = true;
        script.onload = setup;
        document.head.appendChild(script);
    }

    function promptGoogle() {
        if (window.google?.accounts?.id) {
            window.google.accounts.id.prompt();
        }
    }

    return { initGoogle, promptGoogle };
})();
