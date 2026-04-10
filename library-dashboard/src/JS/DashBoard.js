import React from 'react';
import { COLORS } from '../Constants/ColorsUse';
import '../CSS/DashBoard.css';
import { useState,useEffect } from 'react';
import { ResponsiveContainer,AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  } from 'recharts';
import Sidebar from '../Components/SideBar';
const DashBoard = () => {
   const [, setActivities] = useState([]);
  const [loading, setLoading] = useState(true);
  const topBooks = [
    { title: 'The Alchemist', borrows: 128 },
    { title: 'Atomic Habits', borrows: 96 },
    { title: '1984', borrows: 87 },
  ];

  const overdueBooks = [
    { title: 'Dune', member: 'Alice Carter', daysLate: 5 },
    { title: 'Sapiens', member: 'John Doe', daysLate: 3 },
    { title: 'Clean Code', member: 'Marcus Vane', daysLate: 7 },
  ];

  const data = [
  { name: 'Jan', borrowed: 400 },
  { name: 'Feb', borrowed: 300 },
  { name: 'Mar', borrowed: 600 },
  { name: 'Apr', borrowed: 800 },
  { name: 'May', borrowed: 500 },
  { name: 'Jun', borrowed: 900 },
];
 
  useEffect(() => {
    setTimeout(() => {
      setActivities([
        { title: 'The Great Gatsby', action: 'Returned by Marcus Vane', type: 'return' },
        { title: '1984', action: 'Borrowed by Lina Ahmed', type: 'borrow' },
        { title: 'Clean Code', action: 'Overdue for 3 days', type: 'overdue' },
      ]);
      setLoading(false);
    }, 1000);
  }, []);
const metricData = [
  {
    id: 'volumes',
    title: 'Total Volumes',
    value: 42892,
    icon: 'library_books',
    color: COLORS.Secondary,
    chart: [
      { name: 'Available', value: 32000 },
      { name: 'Borrowed', value: 10892 },
    ],
  },
  {
    id: 'members',
    title: 'Active Members',
    value: 8140,
    icon: 'group',
    color: COLORS.Secondary,
    chart: [
      { name: 'Active', value: 7000 },
      { name: 'Inactive', value: 1140 },
    ],
  },
  {
    id: 'borrowed',
    title: 'Borrowed Books',
    value: 1248,
    icon: 'import_contacts',
    color: COLORS.Accent,
    chart: [
      { name: 'Returned', value: 850 },
      { name: 'Still Borrowed', value: 398 },
    ],
  },
  {
    id: 'overdue',
    title: 'Overdue Returns',
    value: 42,
    icon: 'warning',
    color: '#ef4444',
    chart: [
      { name: 'Overdue', value: 42 },
      { name: 'On Time', value: 1206 },
    ],
  },
];

const [selectedMetric, setSelectedMetric] = useState(metricData[0]);

const pieColors = [
  selectedMetric.color,
  '#e5e7eb',
];
  if (loading) return <div className="loader">Loading dashboard...</div>;
  return (
    <div className="dashboard-wrapper"
   
    >
  <Sidebar/>

      <header className="topbar">
        <div className="search-bar">
          <span className="material-symbols-outlined">search</span>
          <input type="text" placeholder="Search volumes, members, or IDs..." />
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
          <span className="material-symbols-outlined" style={{ color: COLORS.Primary }}>notifications</span>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <span className="material-symbols-outlined" style={{ color: COLORS.Accent, fontSize: '30px' }}>account_circle</span>
            <span style={{ fontWeight: 600, fontSize: '0.9rem' }}></span>
          </div>
        </div>
      </header>

      <main className="main-content">
        <section className="hero-section">
          <div>
            <h2 className="hero-title">Institutional Overview</h2>
            <p style={{ color: COLORS.Secondary, fontWeight: 600 }}>Monitoring the pulse of the collection</p>
          </div>
          <div style={{ display: 'flex', gap: '12px' }}>
            <button className="btn-secondary">Check-out</button>
            <button className="btn-primary" style={{ backgroundColor: COLORS.Primary }}>Process Return</button>
          </div>
        </section>

       <section className="metrics-grid">
  {metricData.map((item) => (
    <div
      key={item.id}
      onClick={() => setSelectedMetric(item)}
      className={`stat-card ${selectedMetric.id === item.id ? 'active-stat' : ''}`}
      style={{
        cursor: 'pointer',
        border:
          selectedMetric.id === item.id
            ? `2px solid ${item.color}`
            : '2px solid transparent',
        transform:
          selectedMetric.id === item.id
            ? 'translateY(-4px)'
            : 'translateY(0)',
        transition: 'all 0.3s ease',
      }}
    >
      <span
        className="material-symbols-outlined"
        style={{ color: item.color }}
      >
        {item.icon}
      </span>

      <div>
        <p style={{ fontSize: '0.8rem', opacity: 0.7 }}>{item.title}</p>
        <p
          className="stat-val"
          style={{ color: item.color }}
        >
          {item.value.toLocaleString()}
        </p>
      </div>
    </div>
  ))}
</section>

        <div
  style={{
    background: '#fff',
    borderRadius: '24px',
    padding: '24px',
    marginBottom: '24px',
    boxShadow: '0 10px 30px rgba(0,0,0,0.08)',
    display: 'grid',
    gridTemplateColumns: '1fr 220px',
    gap: '20px',
    alignItems: 'center',
  }}
>
  <div>
    <p
      style={{
        color: '#64748b',
        fontSize: '0.85rem',
        marginBottom: '8px',
      }}
    >
      Selected Metric
    </p>

    <h3
      style={{
        color: selectedMetric.color,
        marginBottom: '8px',
        fontSize: '1.4rem',
      }}
    >
      {selectedMetric.title}
    </h3>

    <p
      style={{
        fontSize: '2rem',
        fontWeight: 800,
        color: COLORS.Primary,
        marginBottom: '16px',
      }}
    >
      {selectedMetric.value.toLocaleString()}
    </p>

    <div style={{ display: 'flex', gap: '18px', flexWrap: 'wrap' }}>
      {selectedMetric.chart.map((entry, index) => (
        <div key={index}>
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
            }}
          >
            <div
              style={{
                width: '12px',
                height: '12px',
                borderRadius: '50%',
                background: pieColors[index],
              }}
            />
            <span style={{ color: '#475569', fontSize: '0.85rem' }}>
              {entry.name}
            </span>
          </div>
          <p
            style={{
              marginLeft: '20px',
              fontWeight: 700,
              color: COLORS.Text,
            }}
          >
            {entry.value.toLocaleString()}
          </p>
        </div>
      ))}
    </div>
  </div>

</div>
        <div className="content-layout">
          
        <div className="chart-container">
      <h3 style={{ color: COLORS.Primary, fontWeight: 800, marginBottom: '20px' }}>
        Borrowing Trends
      </h3>
      
      <div style={{ height: '250px', width: '100%' }}>
        <ResponsiveContainer width="100%" height="100%">
          <AreaChart data={data}>
            <defs>
              <linearGradient id="colorBorrowed" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor={COLORS.Accent} stopOpacity={0.3}/>
                <stop offset="95%" stopColor={COLORS.Accent} stopOpacity={0}/>
              </linearGradient>
            </defs>
            <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#eee" />
            <XAxis 
              dataKey="name" 
              axisLine={false} 
              tickLine={false} 
              tick={{fill: '#94a3b8', fontSize: 12}} 
            />
            <YAxis hide />
            <Tooltip 
              contentStyle={{ borderRadius: '10px', border: 'none', boxShadow: '0 4px 12px rgba(0,0,0,0.1)' }}
            />
            <Area 
              type="monotone" 
              dataKey="borrowed" 
              stroke={COLORS.Accent} 
              fillOpacity={1} 
              fill="url(#colorBorrowed)" 
              strokeWidth={3}
            />
          </AreaChart>
        </ResponsiveContainer>
      </div>
    </div>

          <div className="activity-card">
            <h3 style={{ color: COLORS.Primary, fontWeight: 800, marginBottom: '20px' }}>Live Activity</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
              {[1, 2, 3].map(item => (
                <div key={item} style={{ display: 'flex', gap: '10px', paddingBottom: '10px', borderBottom: '1px solid #eee' }}>
                  <div style={{ width: '8px', height: '40px', background: COLORS.Accent, borderRadius: '10px' }}></div>
                  <div>
                    <p style={{ fontSize: '0.85rem', fontWeight: 700 }}>The Great Gatsby</p>
                    <p style={{ fontSize: '0.7rem', opacity: 0.6 }}>Returned by Marcus Vane</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
       
       
       

        <div className="table-container">
          <h3>Overdue Books</h3>
          <table>
            <thead>
              <tr>
                <th>Book</th>
                <th>Member</th>
                <th>Days Late</th>
              </tr>
            </thead>
            <tbody>
              {overdueBooks.map((book, idx) => (
                <tr key={idx}>
                  <td>{book.title}</td>
                  <td>{book.member}</td>
                  <td>{book.daysLate}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        <div className="top-books-card">
          <h3>Top Borrowed Books</h3>
          <ul>
            {topBooks.map((book, idx) => (
              <li key={idx}>{book.title} — {book.borrows} borrows</li>
            ))}
          </ul>
        </div>
      </main>
   

      <button className="fab">
        <span className="material-symbols-outlined">add</span>
      </button>
    </div>
  );
};

export default DashBoard;