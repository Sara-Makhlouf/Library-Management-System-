import React, { useState } from "react";
import {
  XAxis, YAxis, Tooltip,
  CartesianGrid, ResponsiveContainer, PieChart, Pie, Cell, Legend, AreaChart, Area
} from "recharts";
import { Users, BookOpen, Clock, TrendingUp, Download, Filter } from "lucide-react";
import "../CSS/AnalyistPage.css";

const data = [
  { month: "Jan", borrows: 120, returns: 100 },
  { month: "Feb", borrows: 210, returns: 150 },
  { month: "Mar", borrows: 180, returns: 170 },
  { month: "Apr", borrows: 250, returns: 200 },
  { month: "May", borrows: 300, returns: 280 },
  { month: "Jun", borrows: 280, returns: 210 },
];

const categories = [
  { name: "Science", value: 400 },
  { name: "Novels", value: 300 },
  { name: "History", value: 200 },
  { name: "Tech", value: 278 },
];

const COLORS = ["#FA5C5C", "#FD8A6B", "#FEC288", "#233D4D"];

export default function AnalyistPage() {
  const [timeFrame, setTimeFrame] = useState("Last 6 Months");

  return (
    <div className="analytics-container">
      <header className="analytics-header">
        <div className="title-area">
          <h1>Library Intelligence</h1>
          <p>Real-time data insights & book circulation metrics</p>
        </div>
        
        <div className="action-bar">
          <div className="filter-dropdown">
            <Filter size={16} />
            <select value={timeFrame} onChange={(e) => setTimeFrame(e.target.value)}>
              <option>Last 7 Days</option>
              <option>Last 30 Days</option>
              <option>Last 6 Months</option>
            </select>
          </div>
          <button className="export-btn">
            <Download size={16} />
            Export Data
          </button>
        </div>
      </header>
{/**بهي الصفحة بقدر دخل الai 
 * فيني توصيات + لازم لاقيلا مكان تاني
 * 
 */}
      <div className="stats-grid">
        <StatCard title="Total Borrows" value="1,340" trend="+12.5%" icon={<BookOpen color="#FA5C5C"/>} />
        <StatCard title="Active Members" value="540" trend="+5.2%" icon={<Users color="#FD8A6B"/>} />
        <StatCard title="Overdue Books" value="32" trend="-2.1%" danger icon={<Clock color="#233D4D"/>} />
        <StatCard title="Net Growth" value="18%" trend="+4%" icon={<TrendingUp color="#FEC288"/>} />
      </div>

      <div className="main-grid">
        <div className="chart-card main-chart">
          <div className="card-info">
            <h3>Borrowing vs Returns</h3>
            <span>Comparison of activity flow</span>
          </div>
          <ResponsiveContainer width="100%" height={300}>
            <AreaChart data={data}>
              <defs>
                <linearGradient id="colorBorrows" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#FA5C5C" stopOpacity={0.1}/>
                  <stop offset="95%" stopColor="#FA5C5C" stopOpacity={0}/>
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#eee" />
              <XAxis dataKey="month" axisLine={false} tickLine={false} />
              <YAxis axisLine={false} tickLine={false} />
              <Tooltip />
              <Area type="monotone" dataKey="borrows" stroke="#FA5C5C" fillOpacity={1} fill="url(#colorBorrows)" strokeWidth={3} />
              <Area type="monotone" dataKey="returns" stroke="#233D4D" fill="transparent" strokeWidth={2} strokeDasharray="5 5" />
            </AreaChart>
          </ResponsiveContainer>
        </div>

   
        <div className="chart-card">
          <div className="card-info">
            <h3>Popular Categories</h3>
          </div>
          <ResponsiveContainer width="100%" height={250}>
            <PieChart>
              <Pie data={categories} innerRadius={60} outerRadius={80} paddingAngle={5} dataKey="value">
                {categories.map((_, index) => <Cell key={index} fill={COLORS[index % COLORS.length]} />)}
              </Pie>
              <Tooltip />
              <Legend verticalAlign="bottom" height={36}/>
            </PieChart>
          </ResponsiveContainer>
        </div>

        <div className="chart-card list-card">
          <div className="card-info">
            <h3>Top Borrowers</h3>
          </div>
          <div className="borrower-list">
            {[
              { name: "Ahmad Ali", books: 12, rank: "Gold" },
              { name: "Sara Salem", books: 9, rank: "Silver" },
              { name: "John Doe", books: 7, rank: "Bronze" }
            ].map((user, i) => (
              <div key={i} className="list-item">
                <div className="user-avatar">{user.name[0]}</div>
                <div className="user-info">
                  <h4>{user.name}</h4>
                  <p>{user.books} Books borrowed</p>
                </div>
                <span className={`badge ${user.rank.toLowerCase()}`}>{user.rank}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

function StatCard({ title, value, trend, danger, icon }) {
  return (
    <div className="stat-card">
      <div className="stat-header">
        <div className="icon-bg">{icon}</div>
        <span className={`trend-pill ${danger ? "down" : "up"}`}>{trend}</span>
      </div>
      <div className="stat-body">
        <p>{title}</p>
        <h2>{value}</h2>
      </div>
    </div>
  );
}