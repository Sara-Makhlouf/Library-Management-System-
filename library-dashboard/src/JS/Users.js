import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { Search, UserPlus, MoreVertical,} from 'lucide-react';
import '../CSS/Barrow.css';
import '../CSS/Variables.css';
export default function UsersPage() {
  const [users] = useState([
    { id: 1, name: 'Ahmad Al-Saeed', email: 'ahmad@example.com', role: 'Student', joined: '2024-01-12', status: 'Active' },
    { id: 2, name: 'Laila Mahmoud', email: 'laila@example.com', role: 'Faculty', joined: '2023-11-05', status: 'Inactive' },
       { id: 2, name: 'Laila Mahmoud', email: 'laila@example.com', role: 'Faculty', joined: '2023-11-05', status: 'Inactive' },
    { id: 2, name: 'Laila Mahmoud', email: 'laila@example.com', role: 'Faculty', joined: '2023-11-05', status: 'Inactive' },
    { id: 2, name: 'Laila Mahmoud', email: 'laila@example.com', role: 'Faculty', joined: '2023-11-05', status: 'Inactive' },
    { id: 2, name: 'Laila Mahmoud', email: 'laila@example.com', role: 'Faculty', joined: '2023-11-05', status: 'Inactive' },
    { id: 2, name: 'Laila Mahmoud', email: 'laila@example.com', role: 'Faculty', joined: '2023-11-05', status: 'Inactive' },
    { id: 2, name: 'Laila Mahmoud', email: 'laila@example.com', role: 'Faculty', joined: '2023-11-05', status: 'Inactive' },
    { id: 2, name: 'Laila Mahmoud', email: 'laila@example.com', role: 'Faculty', joined: '2023-11-05', status: 'Inactive' },

   
   
  ]);

  return (
    <div className="page-container">
      
      <header className="page-header">
        <div>
          <h1>User Directory</h1>
          <p>Manage and monitor your library members</p>
        </div>
        <button className="primary-btn"><UserPlus size={18}/> Add New User</button>
      </header>

      <div className="stats-grid">
        <div className="mini-stat"><h4>Total Users</h4> <span>1,240</span></div>
        <div className="mini-stat"><h4>Active Now</h4> <span>85</span></div>
        <div className="mini-stat"><h4>New This Month</h4> <span>12</span></div>
      </div>

      <div className="table-container">
        <div className="table-actions">
          <div className="search-bar">
            <Search size={18} />
            <input type="text" placeholder="Search by name, email or ID..." />
          </div>
        </div>

        <table className="custom-table">
          <thead>
            <tr>
              <th>Member Name</th>
              <th>Role</th>
              <th>Joined Date</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {users.map(user => (
              <motion.tr key={user.id} initial={{ opacity: 0 }} animate={{ opacity: 1 }}>
                <td>
                  <div className="user-info">
                    <div className="user-avatar">{user.name.charAt(0)}</div>
                    <div>
                      <div className="name">{user.name}</div>
                      <div className="email">{user.email}</div>
                    </div>
                  </div>
                </td>
                <td><span className="badge role">{user.role}</span></td>
                <td>{user.joined}</td>
                <td><span className={`status-dot ${user.status.toLowerCase()}`}>{user.status}</span></td>
                <td><button className="icon-btn"><MoreVertical size={16}/></button></td>
              </motion.tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}