// Calvary Portal: injects the persistent app navigation. Call
// CalvaryNav.render(activePage, profile) once auth state is known.
// activePage is one of: 'home', 'watch', 'account', 'team'.
const CalvaryNav = (function () {
  function render(activePage, profile) {
    document.body.classList.add("has-app-nav");
    const canSeeTeam = profile && profile.roles && profile.roles.some(r =>
      ["staff", "admin", "volunteer", "media"].includes(r)
    );

    const items = [
      { key: "home", href: "home.html", icon: "&#127968;", label: "Home" },
      { key: "watch", href: "watch.html", icon: "&#128214;", label: "Watch & Study" },
      { key: "account", href: "account.html", icon: "&#128100;", label: "My Account" },
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

    // On desktop the nav renders as a top bar, so it needs to sit inside
    // .wrap to align with page content rather than spanning full width.
    const wrap = document.querySelector(".wrap");
    if (wrap && window.innerWidth >= 760) {
      wrap.insertBefore(nav, wrap.firstChild);
    }
  }
  return { render };
})();
