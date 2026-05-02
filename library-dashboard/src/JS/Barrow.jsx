import React from 'react';
import { BookOpen, UserCheck, Calendar as CalendarIcon, ArrowRightLeft } from 'lucide-react';
import '../CSS/Barrow.css';
import '../CSS/Variables.css';

export default function CirculationPage() {
  return (
    <div className="page-container">
      <header className="page-header">
        <h1>Book Circulation</h1>
        <p>Issue or Return books instantly</p>
      </header>

      <div className="circulation-grid">
        <section className="circulation-card">
          <div className="card-header">
            <ArrowRightLeft color="#FA5C5C" />
            <h2>New Loan</h2>
          </div>
          <div className="loan-inputs">
            <div className="input-group">
              <label><UserCheck size={16}/> Member ID</label>
              <input type="text" placeholder="Enter member ID or scan badge" />
            </div>
            <div className="input-group">
              <label><BookOpen size={16}/> Book ISBN / ID</label>
              <input type="text" placeholder="Scan book barcode" />
            </div>
            <div className="input-group">
              <label><CalendarIcon size={16}/> Return Date</label>
              <input type="date" defaultValue="2024-05-10" />
            </div>
            <button className="primary-btn full-width">Complete Loan Transaction</button>
          </div>
        </section>

        <section className="recent-activity">
          <h3>Recent Transactions</h3>
          <div className="activity-list">
            {[1, 2, 3].map(i => (
              <div className="activity-item" key={i}>
                <div className="activity-icon return">↺</div>
                <div className="activity-details">
                  <p><strong>"Atomic Habits"</strong> returned by Ahmad</p>
                  <span>2 mins ago</span>
                </div>
              </div>
            ))}
          </div>
        </section>
      </div>
    </div>
  );
}