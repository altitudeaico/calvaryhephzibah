// Calvary Portal: injects the persistent app navigation. Call
// CalvaryNav.render(activePage, profile) once auth state is known.
// activePage is one of: 'home', 'watch', 'account', 'team'.
//
// FIXED after live testing: this used to only be called when a session
// existed, so signed-out visitors saw no navigation at all on Watch &
// Study or the guided study -- exactly the pages meant to work without
// signing in. Nav must render unconditionally; `profile` may be null.
const CalvaryNav = (function () {
  function render(activePage, profile) {
    document.body.classList.add("has-app-nav");
    const isSignedIn = !!profile;
    const canSeeTeam = profile && profile.roles && profile.roles.some(r =>
      ["staff", "admin", "volunteer", "media"].includes(r)
    );

    const items = [
      { key: "home", href: isSignedIn ? "home.html" : "index.html", icon: "&#127968;", label: "Home" },
      { key: "watch", href: "watch.html", icon: "&#128214;", label: "Watch & Study" },
      { key: "account", href: isSignedIn ? "account.html" : "login.html?next=account.html", icon: "&#128100;", label: "My Account" },
    ];
    if (canSeeTeam) {
      items.push({ key: "team", href: "team.html", icon: "&#128101;", label: "Team" });
    }

    const nav = document.createElement("nav");
    nav.className = "app-nav";
    nav.innerHTML = items.map(item =>
      `<a href="${item.href}" class="${item.key === activePage ? 'active' : ''}">
         <span class="nav-icon">${item.icon}</span><span>${item.label}</span>
       </a>`
    ).join("");
    document.body.insertBefore(nav, document.body.firstChild);

    const wrap = document.querySelector(".wrap");
    if (wrap && window.innerWidth >= 760) {
      wrap.insertBefore(nav, wrap.firstChild);
    }
  }
  return { render };
})();
