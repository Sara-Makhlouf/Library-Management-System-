import React, { useState, useEffect } from 'react';
import Sidebar from '../Components/SideBar';

import { motion, AnimatePresence } from 'framer-motion';
import { 
  User, Book, Shield, Database, 
  Save,  Camera, LogOut,
  Users, Key, Activity, Zap,
 
} from 'lucide-react';
import '../CSS/Setting.css';
export default function LibrarySettings() {
  const [activeTab, setActiveTab] = useState('profile');
  const [isSaving, setIsSaving] = useState(false);
  const [darkMode,] = useState(false);
  const [language, ] = useState('en');

  const [settings, setSettings] = useState({
    name: 'Admin User',
    role: 'Head Librarian',
    email: 'admin@library.com',
    libName: 'Central Knowledge Library',
    loanPeriod: 14,
    maxBooks: 5,
    finePerDay: 2.5,
    notifyEmail: true,
    notifySMS: false,
    autoBackup: true,
    twoFactor: true
  });

  useEffect(() => {
    document.documentElement.setAttribute('data-theme', darkMode ? 'dark' : 'light');
  }, [darkMode]);

  const handleInputChange = (e) => {
    const { name, value, type, checked } = e.target;
    setSettings({ ...settings, [name]: type === 'checkbox' ? checked : value });
  };

  const menuItems = [
    { id: 'profile', label: 'Admin Profile', icon: <User size={20} /> },
    { id: 'library', label: 'Library Rules', icon: <Book size={20} /> },
    { id: 'appearance', label: 'Customization', icon: <Zap size={20} /> },
    { id: 'users', label: 'User Roles', icon: <Users size={20} /> },
    { id: 'security', label: 'Privacy & Security', icon: <Shield size={20} /> },
    { id: 'system', label: 'System Health', icon: <Activity size={20} /> },
  ];

  return (
    <div className={`settings-wrapper ${language === 'ar' ? 'rtl' : 'ltr'}`}>
                <Sidebar/>

      <div className="settings-container">
        <aside className="settings-sidebar">
          <div className="profile-section">
            <div className="avatar-wrapper">
              <img src={`https://ui-avatars.com/api/?name=${settings.name}&background=FA5C5C&color=fff`} alt="Profile" />
              <button className="edit-avatar"><Camera className='cam' size={14} /></button>
            </div>
            <h3>{settings.name}</h3>
            <span className="role-badge">{settings.role}</span>
          </div>

          <nav className="sidebar-nav">
            {menuItems.map((item) => (
              <button
                key={item.id}
                onClick={() => setActiveTab(item.id)}
                className={activeTab === item.id ? 'nav-item active' : 'nav-item'}
              >
                {item.icon}
                <span>{item.label}</span>
              </button>
            ))}
          </nav>

          <button className="logout-btn">
            <LogOut size={18} />
            <span>Sign Out</span>
          </button>
        </aside>

        <main className="settings-main">
          <header className="main-header">
            <div className="header-info">
              <h1>{menuItems.find(i => i.id === activeTab).label}</h1>
              <p>Configure your library environment using the professional dashboard.</p>
            </div>
            <button className="save-btn" onClick={() => setIsSaving(true)} disabled={isSaving}>
              <Save size={18} />
              {isSaving ? 'Synchronizing...' : 'Apply Changes'}
            </button>
          </header>

          <AnimatePresence mode="wait">
            <motion.div
              key={activeTab}
              initial={{ opacity: 0, y: 15 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -15 }}
              className="content-card"
            >
              
              {activeTab === 'profile' && (
                <div className="form-grid">
                  <div className="input-group">
                    <label>Full Display Name</label>
                    <input type="text" name="name" value={settings.name} onChange={handleInputChange} />
                  </div>
                  <div className="input-group">
                    <label>Job Title / Role</label>
                    <input type="text" name="role" value={settings.role} onChange={handleInputChange} />
                  </div>
                  <div className="input-group full-width">
                    <label>Official Email Address</label>
                    <input type="email" name="email" value={settings.email} onChange={handleInputChange} />
                  </div>
                  <div className="info-alert">
                    <p>Your profile information is visible to other staff members.</p>
                  </div>
                </div>
              )}

              {activeTab === 'library' && (
                <div className="form-section">
                   <div className="input-group">
                    <label>Institution Name</label>
                    <input type="text" name="libName" value={settings.libName} onChange={handleInputChange} />
                  </div>
                  <div className="input-grid">
                    <div className="input-group">
                      <label>Borrowing Limit (Days)</label>
                      <input type="number" name="loanPeriod" value={settings.loanPeriod} onChange={handleInputChange} />
                    </div>
                    <div className="input-group">
                      <label>Overdue Fine ($/Day)</label>
                      <input type="number" step="0.1" name="finePerDay" value={settings.finePerDay} onChange={handleInputChange} />
                    </div>
                  </div>
                </div>
              )}

              {activeTab === 'security' && (
                <div className="form-section">
                  <div className="toggle-card">
                    <div className="toggle-info">
                      <h4>Two-Factor Authentication</h4>
                      <p>Secure your account with an extra layer of protection.</p>
                    </div>
                    <label className="switch-ui">
                      <input type="checkbox" name="twoFactor" checked={settings.twoFactor} onChange={handleInputChange} />
                      <span className="slider"></span>
                    </label>
                  </div>
                  <div className="input-group">
                    <label>Current Password</label>
                    <input type="password" placeholder="••••••••" />
                  </div>
                  <button className="action-btn-outline"><Key size={16}/> Change Password</button>
                </div>
              )}

              {activeTab === 'system' && (
                <div className="stats-container">
                  <div className="stat-box">
                    <Database size={24} color="#FA5C5C"/>
                    <div>
                      <span>Storage Used</span>
                      <strong>1.2 GB / 5 GB</strong>
                    </div>
                  </div>
                  <div className="stat-box">
                    <Activity size={24} color="#FD8A6B"/>
                    <div>
                      <span>Server Uptime</span>
                      <strong>99.9%</strong>
                    </div>
                  </div>
                </div>
              )}

            </motion.div>
          </AnimatePresence>
        </main>
      </div>
    </div>
  );
}