const tabs = document.querySelectorAll("[data-tab-container]");

const tabListeners = {};
Array.from(tabs || []).forEach((tabContainer) => {
  const tabButtons = Array.from(
    tabContainer.querySelectorAll(".tabs button") || []
  );
  const tabs = Array.from(tabContainer.querySelectorAll(".tab") || []);

  tabButtons.forEach((button) => {
    const tab = tabs.find((tab) => tab.dataset.tab === button.dataset.tab);
    if (!tab) {
      console.error("no related tab found", button.dataset.tab, tabContainer);
      return;
    }

    button.addEventListener("click", () => {
      tabButtons.forEach((button) => button.classList.remove("active"));
      button.classList.add("active");
      tabs.forEach((tab) => tab.classList.add("hide"));
      tab.classList.remove("hide");
      tabListeners[tabContainer.dataset.tabContainer]?.[button.dataset.tab]?.();
    });
  });
});

const listenToTab = (id, tab, fn) => {
  if (!tabListeners[id]) {
    tabListeners[id] = {};
  }

  tabListeners[id][tab] = fn;
};

module.exports = { listenToTab };