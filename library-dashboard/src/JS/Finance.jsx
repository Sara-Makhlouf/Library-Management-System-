import React from 'react';
import {  TrendingUp, AlertCircle, Download } from 'lucide-react';
import '../CSS/Finance.css';
import '../CSS/Variables.css';

export default function FinancePage() {
  return (
    <div className="page-container">
        <div  className='page-content'>
           <header className="page-header">
        <div>
          <h1>Financial Overview</h1>
          <p>Track library revenue and pending fines</p>
        </div>
        <button className="primary-btn"><Download size={18}/> Export Report</button>
      </header>

      <div className="stats-grid">
        <div className="mini-stat">
          <h4>Collected Fines</h4> <span>$1,420.50</span>
          <TrendingUp size={20} className="stat-icon-trend" />
        </div>
        <div className="mini-stat">
          <h4>Pending Fines</h4> <span style={{color: 'var(--primary)'}}>$320.00</span>
          <AlertCircle size={20} color="var(--primary)" />
        </div>
      </div>

      <div className="table-container">
        <h3>Recent Transactions</h3>
        <table className="custom-table">
          <thead>
            <tr>
              <th>Member</th>
              <th>Reason</th>
              <th>Amount</th>
              <th>Date</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Sara Makhlouf</td>
              <td>Late Return (3 days)</td>
              <td><strong>$7.50</strong></td>
              <td>April 12, 2026</td>
              <td><span className="badge-paid">Paid</span></td>
            </tr>
          </tbody>
        </table>
        </div>
     
      </div>
    </div>
  );
}