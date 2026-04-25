import React from 'react';
import { Archive,  History, Search } from 'lucide-react';
import '../CSS/Finance.css';
import '../CSS/Variables.css';

import Sidebar from '../Components/SideBar';
export default function ArchivesPage() {
  return (
   <div className="page-container">
  <Sidebar/>

  <div className="page-content">
    <header className="page-header">
      <h1>Archives Vault</h1>

      <div className="header-actions">
        <div className="search-bar-mini">
          <Search size={16} />
          <input type="text" placeholder="Search archive..." />
        </div>
      </div>
    </header>

    <div className="archive-grid">
      <div className="archive-card">
        <div className="archive-icon"><History size={30} /></div>
        <h3>System Logs 2025</h3>
        <p>All checkout history for the previous academic year.</p>
        <button className="text-btn">View Records</button>
      </div>

      <div className="archive-card">
        <div className="archive-icon"><Archive size={30} /></div>
        <h3>Decommissioned Books</h3>
        <p>Books removed from inventory (Lost/Damaged).</p>
        <button className="text-btn">View List</button>
      </div>
    </div>
  </div>
</div>
  );
}