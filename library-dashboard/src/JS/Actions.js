import React from 'react';
import { UploadCloud, RefreshCw} from 'lucide-react';
import '../CSS/Finance.css';
import '../CSS/Variables.css';

export default function ActionsPage() {
  return (
    <div className="page-container">
      <header className="page-header"
      
      >
        <h1>Quick Actions</h1>
        <p>Advanced system operations and bulk processing</p>
      </header>

      <div className="actions-layout">
        <div className="action-tile">
          <div className="tile-header">
            <UploadCloud size={24} color="var(--primary)" />
            <h3>Bulk Import</h3>
          </div>
          <p>Upload Excel/CSV files to add multiple books or users at once.</p>
          <button className="action-btn">Launch Importer</button>
        </div>

        <div className="action-tile">
          <div className="tile-header">
            <RefreshCw size={24} color="var(--secondary)" />
            <h3>Sync Database</h3>
          </div>
          <p>Synchronize local records with the cloud backup server.</p>
          <button className="action-btn">Start Sync</button>
        </div>
      </div>
    </div>
  );
}