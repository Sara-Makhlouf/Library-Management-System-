import { Link } from "react-router-dom";
import { COLORS } from "../Constants/ColorsUse";
import '../CSS/SideBar.css';
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
        <Link to="/dashboard" className="nav-item active">
          <span className="material-symbols-outlined">dashboard</span>
          Dashboard
        </Link>

        <Link to="/inventor" className="nav-item">
          <span className="material-symbols-outlined">menu_book</span>
          Book Inventory
        </Link>
       
         <Link to="/users" className="nav-item">
          <span className="material-symbols-outlined">person</span>
          Users
        </Link>
         <Link to="/reports" className="nav-item">
          <span className="material-symbols-outlined">report</span>
         Reports
        </Link>

         <Link to="/notification" className="nav-item">
  <span className="material-symbols-outlined">notifications</span>
  Notification
</Link>
<Link to="/circulation" className="nav-item">
  <span className="material-symbols-outlined">sync_alt</span>
  Circulations
</Link>
        <Link to="/finances" className="nav-item">
            <span className="material-symbols-outlined">payments</span>
            Finances</Link>
              <Link to="/archives" className="nav-item">
            <span className="material-symbols-outlined">archives</span>
            Archives</Link>
             <Link to="/actions" className="nav-item">
            <span className="material-symbols-outlined">manage_search</span>
            Actions</Link>
<Link to="/settings" className="nav-item">
  <span className="material-symbols-outlined">settings</span>
  Settings
</Link>

      </nav>

      <div className="sidebar-profile">
        <div className="avatar">
          <img src="/avatar.jpg" alt="Female Avatar" />
        </div>

        <div className="profile-info">
          <p className="profile-name">Sara Makhlouf</p>
          <p className="profile-role">Admin Portal</p>
        </div>
      </div>
    </aside>
  );
}