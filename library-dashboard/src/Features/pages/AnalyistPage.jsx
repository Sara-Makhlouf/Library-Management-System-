import React, { useState } from "react";
import {
  XAxis, YAxis, Tooltip,
  CartesianGrid, ResponsiveContainer, PieChart, Pie, Cell, Legend, AreaChart, Area
} from "recharts";

import { Users, BookOpen, Clock, TrendingUp, Download, Filter } from "lucide-react";
import { COLORS } from "../../Core/Constants/ColorsUse";
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


export default function AnalyistPage() {
  const [timeFrame, setTimeFrame] = useState("Last 6 Months");

  return (
    <div
      style={{
        padding: "30px",
        minHeight: "100vh",
        background: "linear-gradient(135deg,#f8f6ef,#efe9dc)",
      }}
    >
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          marginBottom: "30px",
        }}
      >
        <div>
          <h1 style={{ margin: 0 }}>Library Intelligence ✨</h1>
          <p style={{ opacity: 0.6 }}>
            Real-time analytics & circulation insights
          </p>
        </div>

        <div style={{ display: "flex", gap: "10px" }}>
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: "6px",
              background: "white",
              padding: "8px 12px",
              borderRadius: "10px",
            }}
          >
            <Filter size={14} />
            <select
              value={timeFrame}
              onChange={(e) => setTimeFrame(e.target.value)}
              style={{ border: "none", outline: "none" }}
            >
              <option>Last 7 Days</option>
              <option>Last 30 Days</option>
              <option>Last 6 Months</option>
            </select>
          </div>

          <button
            style={{
              background: "#B8A068",
              color: "white",
              border: "none",
              padding: "10px 14px",
              borderRadius: "10px",
              display: "flex",
              gap: "6px",
              cursor: "pointer",
            }}
          >
            <Download size={14} />
            Export
          </button>
        </div>
      </div>

      {/* STATS */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit,minmax(200px,1fr))",
          gap: "20px",
          marginBottom: "30px",
        }}
      >
        <StatCard title="Total Borrows" value="1,340" trend="+12%" icon={<BookOpen />} />
        <StatCard title="Members" value="540" trend="+5%" icon={<Users />} />
        <StatCard title="Overdue" value="32" trend="-2%" danger icon={<Clock />} />
        <StatCard title="Growth" value="18%" trend="+4%" icon={<TrendingUp />} />
      </div>

      {/* MAIN GRID */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "2fr 1fr",
          gap: "20px",
        }}
      >
        {/* AREA CHART */}
        <div style={cardStyle}>
          <h3>Borrow vs Return</h3>

          <ResponsiveContainer width="100%" height={300}>
            <AreaChart data={data}>
              <defs>
                <linearGradient id="grad1" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#B8A068" stopOpacity={0.2}/>
                  <stop offset="95%" stopColor="#B8A068" stopOpacity={0}/>
                </linearGradient>
              </defs>

              <CartesianGrid stroke="#eee" vertical={false}/>
              <XAxis dataKey="month" />
              <YAxis />
              <Tooltip />

              <Area
                type="monotone"
                dataKey="borrows"
                stroke="#B8A068"
                fill="url(#grad1)"
                strokeWidth={3}
              />

              <Area
                type="monotone"
                dataKey="returns"
                stroke="#333"
                strokeDasharray="5 5"
              />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        {/* PIE + LIST */}
        <div style={{ display: "flex", flexDirection: "column", gap: "20px" }}>
          {/* PIE */}
          <div style={cardStyle}>
            <h3>Categories</h3>

            <ResponsiveContainer width="100%" height={220}>
              <PieChart>
                <Pie data={categories} dataKey="value" innerRadius={50}>
                  {categories.map((_, i) => (
                    <Cell key={i} fill={COLORS[i]} />
                  ))}
                </Pie>
                <Tooltip />
                <Legend />
              </PieChart>
            </ResponsiveContainer>
          </div>

          {/* TOP USERS */}
          <div style={cardStyle}>
            <h3>Top Borrowers</h3>

            {[
              { name: "Ahmad Ali", books: 12 },
              { name: "Sara Salem", books: 9 },
              { name: "John Doe", books: 7 },
            ].map((u, i) => (
              <div
                key={i}
                style={{
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "space-between",
                  padding: "10px 0",
                  borderBottom: "1px solid #eee",
                }}
              >
                <div style={{ display: "flex", gap: "10px" }}>
                  <div
                    style={{
                      width: 35,
                      height: 35,
                      borderRadius: "50%",
                      background: "#B8A068",
                      color: "white",
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                    }}
                  >
                    {u.name[0]}
                  </div>

                  <div>
                    <div>{u.name}</div>
                    <small>{u.books} books</small>
                  </div>
                </div>

                <span style={{ fontSize: "0.8rem", opacity: 0.6 }}>
                  #{i + 1}
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

const cardStyle = {
  background: "rgba(255,255,255,0.8)",
  padding: "20px",
  borderRadius: "20px",
  backdropFilter: "blur(10px)",
  boxShadow: "0 10px 30px rgba(0,0,0,0.08)",
};

function StatCard({ title, value, trend, danger, icon }) {
  return (
    <div
      style={{
        background: "white",
        borderRadius: "16px",
        padding: "20px",
        boxShadow: "0 8px 20px rgba(0,0,0,0.06)",
      }}
    >
      <div style={{ display: "flex", justifyContent: "space-between" }}>
        {icon}
        <span style={{ color: danger ? "red" : "green" }}>{trend}</span>
      </div>

      <h2 style={{ margin: "10px 0 0 0" }}>{value}</h2>
      <p style={{ opacity: 0.6 }}>{title}</p>
    </div>
  );
}