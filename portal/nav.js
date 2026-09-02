// Calvary Portal: injects the persistent app navigation, using the shared
// icon set instead of emoji. Call CalvaryNav.render(activePage, profile).
const CalvaryNav = (function () {
  function render(activePage, profile) {
    document.body.classList.add("has-app-nav");
    const isSignedIn = !!profile;
    const canSeeTeam = profile && profile.roles && profile.roles.some(r =>
      ["staff", "admin", "volunteer", "media"].includes(r)
    );

    const items = [
      { key: "home", href: isSignedIn ? "home.html" : "index.html", icon: CalvaryIcons.home, label: "Home" },
      { key: "watch", href: "watch.html", icon: CalvaryIcons.book, label: "Watch & Study" },
      { key: "account", href: isSignedIn ? "account.html" : "login.html?next=account.html", icon: CalvaryIcons.person, label: "My Account" },
    ];
    if (canSeeTeam) {
      items.push({ key: "team", href: "team.html", icon: CalvaryIcons.people, label: "Team" });
    }

    const nav = document.createElement("nav");
    nav.className = "app-nav";
    nav.innerHTML = items.map(item =>
      `<a href="${item.href}" class="${item.key === activePage ? 'active' : ''}">
         ${item.icon}<span>${item.label}</span>
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
