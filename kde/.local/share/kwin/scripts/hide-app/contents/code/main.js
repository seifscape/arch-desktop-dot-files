// Like Cmd+H on macOS: minimize every window of the focused app.
// Clicking the app in the task bar brings its windows back.
registerShortcut("HideApp", "Hide App", "Meta+H", function () {
    const active = workspace.activeWindow;
    if (!active || !active.normalWindow) return;
    for (const w of workspace.windowList()) {
        if (w.resourceClass === active.resourceClass && w.normalWindow && w.minimizable) {
            w.minimized = true;
        }
    }
});
