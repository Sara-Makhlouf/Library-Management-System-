import { NavLink } from "react-router-dom";
import { COLORS } from "../Constants/ColorsUse";
import "../CSS/SideBar.css";
import "../CSS/Variables.css";

export default function Sidebar() {
  return (
    <aside className="sidebar">
      <div className="brand-header">
        <h1 className="brand-h1">Scholarly Curator</h1>
        <span
          style={{
            fontSize: "0.6rem",
            color: COLORS.Secondary,
            fontWeight: 800,
            letterSpacing: "2px",
          }}
        >
          INSTITUTIONAL LMS
        </span>
      </div>

      <nav className="nav-links">

        <NavLink to="/dashboard" className="nav-item" end>
          <span className="material-symbols-outlined">dashboard</span>
          Dashboard
        </NavLink>

        <NavLink to="/inventory" className="nav-item" end>
          <span className="material-symbols-outlined">menu_book</span>
          Book Inventory
        </NavLink>

        <NavLink to="/users" className="nav-item" end>
          <span className="material-symbols-outlined">person</span>
          Users
        </NavLink>

        <NavLink to="/analytics" className="nav-item" end>
          <span className="material-symbols-outlined">analytics</span>
          Analytics
        </NavLink>

        <NavLink to="/actions" className="nav-item" end>
          <span className="material-symbols-outlined">manage_search</span>
          Actions
        </NavLink>


        <NavLink to="/circulation" className="nav-item" end>
          <span className="material-symbols-outlined">sync_alt</span>
          Circulation
        </NavLink>

        <NavLink to="/finance" className="nav-item" end>
          <span className="material-symbols-outlined">payments</span>
          Finances
        </NavLink>

        <NavLink to="/archives" className="nav-item" end>
          <span className="material-symbols-outlined">archive</span>
          Archives
        </NavLink>

        <NavLink to="/notifications" className="nav-item" end>
          <span className="material-symbols-outlined">notifications</span>
          Notifications
        </NavLink>

        <NavLink to="/settings" className="nav-item" end>
          <span className="material-symbols-outlined">settings</span>
          Settings
        </NavLink>

      </nav>

      <div className="sidebar-profile">
        <div className="avatar">
          <img src="/avatar.jpg" alt="Admin Avatar" />
        </div>

        <div className="profile-info">
          <p className="profile-name">Sara Makhlouf</p>
          <p className="profile-role">Admin Portal</p>
        </div>
      </div>
    </aside>
  );
}