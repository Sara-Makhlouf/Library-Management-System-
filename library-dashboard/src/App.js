import React, { useState } from "react";
import { Toaster } from "react-hot-toast";
import AppRouter from "./Core/Constants/AppRouter.jsx";
import Sidebar from "./Core/Components/SideBar.jsx";
import { useLocation } from "react-router-dom";
import { store } from "./Core/Redux/Store/Store.jsx";
import { Provider } from "react-redux";

function App() {
  const location = useLocation();

  const [collapsed, setCollapsed] = useState(false);

  const hideSidebar = location.pathname === "/";

  return (
    <Provider store={store}>
      <>
        {!hideSidebar && (
          <Sidebar
            collapsed={collapsed}
            setCollapsed={setCollapsed}
          />
        )}

        <main
          style={{
            minHeight: "100vh",
            display: "block",
            
            marginLeft: hideSidebar
              ? 0
              : collapsed
              ? 84
              : 256,
            transition: "margin-left 0.3s ease",
          }}
        >
          <AppRouter />
        </main>

        <Toaster position="top-right" />
      </>
    </Provider>
  );
}

export default App;