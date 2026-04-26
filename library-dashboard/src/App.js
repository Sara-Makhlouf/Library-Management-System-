import React from 'react';
import { Toaster } from "react-hot-toast";
import AppRouter from './Constants/AppRouter.jsx';
import Sidebar from './Components/SideBar.js';
import { useLocation } from "react-router-dom";


function App() {
  const location = useLocation();

  const hideSidebar = location.pathname === "/";

  return (
    <>
      {!hideSidebar && <Sidebar />}

      <main style={{ minHeight: "100vh", display: "block" }}>
        <AppRouter />
      </main>

      <Toaster position="top-right" />
    </>
  );
}

export default App;

