import React, { useState,useRef } from "react";
import {
  XAxis, YAxis, Tooltip, CartesianGrid, ResponsiveContainer, 
  PieChart, Pie, Cell, AreaChart, Area
} from "recharts";
import { Users, BookOpen, Clock, TrendingUp, Download, Filter } from "lucide-react";
import html2canvas from "html2canvas";
import jsPDF from "jspdf";
import {
  Box,
  Button,
Paper, 
  Typography,
 
} from "@mui/material";
const COLORS = ["#c9a84c", "#4ade80", "#3b82f6", "#f472b6"];

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
  const [timeFrame] = useState("Last 6 Months");
const pageRef = useRef(null);

const handleExport = async () => {
  try {
    const canvas = await html2canvas(pageRef.current, {
      scale: 2,
      useCORS: true,
      backgroundColor: "#0a0a0f",
    });

    const imgData = canvas.toDataURL("image/png");

    const pdf = new jsPDF("p", "mm", "a4");

    const pdfWidth = pdf.internal.pageSize.getWidth();
    const pdfHeight = pdf.internal.pageSize.getHeight();

    const imgWidth = pdfWidth;
    const imgHeight = (canvas.height * imgWidth) / canvas.width;

    let heightLeft = imgHeight;
    let position = 0;

    pdf.addImage(imgData, "PNG", 0, position, imgWidth, imgHeight);
    heightLeft -= pdfHeight;

    while (heightLeft > 0) {
      position = heightLeft - imgHeight;
      pdf.addPage();
      pdf.addImage(imgData, "PNG", 0, position, imgWidth, imgHeight);
      heightLeft -= pdfHeight;
    }

    pdf.save("Library_Analytics.pdf");
  } catch (error) {
    console.error("Export failed:", error);
  }
};
  return (
<Box
  ref={pageRef}
  sx={{
    minHeight: "100vh",
    bgcolor: "#0a0a0f",
    p: 3,
    color: "#fff",
    fontFamily: "Inter, sans-serif",
  }}
>      
      <Box sx={{ mb: 4, display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <Box>
          <Typography sx={{ fontSize: 28, fontWeight: 800, color: "#fff" }}>Library Intelligence ✨</Typography>
          <Typography sx={{ color: "rgba(255,255,255,0.4)", fontSize: 14 }}>Real-time analytics & circulation insights</Typography>
        </Box>
        
        <Box sx={{ display: "flex", gap: 2 }}>
          <Button variant="outlined" sx={{ borderColor: "rgba(255,255,255,0.1)", color: "#fff" }}>
            <Filter size={16} style={{ marginRight: 8 }} /> {timeFrame}
          </Button>
         <Button
  onClick={handleExport}
  sx={{
    bgcolor: "#c9a84c",
    color: "#000",
    fontWeight: 700,
    "&:hover": { bgcolor: "#b89740" },
  }}
>
  <Download size={16} style={{ marginRight: 8 }} />
  Export
</Button>
        </Box>
      </Box>

      <Box sx={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))", gap: 3, mb: 4 }}>
        <StatCard title="Total Borrows" value="1,340" trend="+12%" icon={<BookOpen />} />
        <StatCard title="Members" value="540" trend="+5%" icon={<Users />} />
        <StatCard title="Overdue" value="32" trend="-2%" danger icon={<Clock />} />
        <StatCard title="Growth" value="18%" trend="+4%" icon={<TrendingUp />} />
      </Box>

      <Box sx={{ display: "grid", gridTemplateColumns: { xs: "1fr", md: "2fr 1fr" }, gap: 3 }}>
        <CardWrapper title="Borrow vs Return">
          <ResponsiveContainer width="100%" height={300}>
            <AreaChart data={data}>
              <defs>
                <linearGradient id="grad1" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#c9a84c" stopOpacity={0.3}/>
                  <stop offset="95%" stopColor="#c9a84c" stopOpacity={0}/>
                </linearGradient>
              </defs>
              <CartesianGrid stroke="#222" vertical={false}/>
              <XAxis dataKey="month" stroke="#666" />
              <YAxis stroke="#666" />
              <Tooltip contentStyle={{ backgroundColor: "#111118", border: "none" }} />
              <Area type="monotone" dataKey="borrows" stroke="#c9a84c" fill="url(#grad1)" strokeWidth={3} />
              <Area type="monotone" dataKey="returns" stroke="#fff" strokeDasharray="5 5" fill="none" />
            </AreaChart>
          </ResponsiveContainer>
        </CardWrapper>

        <Box sx={{ display: "flex", flexDirection: "column", gap: 3 }}>
          <CardWrapper title="Categories">
            <ResponsiveContainer width="100%" height={220}>
              <PieChart>
                <Pie data={categories} dataKey="value" innerRadius={60} outerRadius={80}>
                  {categories.map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
                </Pie>
                <Tooltip contentStyle={{ backgroundColor: "#111118", border: "none" }} />
              </PieChart>
            </ResponsiveContainer>
          </CardWrapper>
        </Box>
      </Box>
    </Box>
  );
}

function CardWrapper({ title, children }) {
  return (
    <Paper sx={{ p: 3, bgcolor: "#111118", borderRadius: "20px", border: "1px solid rgba(255,255,255,0.06)" }}>
      <Typography sx={{ mb: 2, fontWeight: 700 }}>{title}</Typography>
      {children}
    </Paper>
  );
}

function StatCard({ title, value, trend, danger, icon }) {
  return (
    <Paper sx={{ p: 3, bgcolor: "#111118", borderRadius: "20px", border: "1px solid rgba(255,255,255,0.06)" }}>
      <Box sx={{ display: "flex", justifyContent: "space-between", mb: 2, color: "#c9a84c" }}>
        {icon}
        <Typography sx={{ color: danger ? "#ff4d4d" : "#4ade80", fontSize: 12, fontWeight: 700 }}>{trend}</Typography>
      </Box>
      <Typography variant="h4" sx={{ fontWeight: 800 }}>{value}</Typography>
      <Typography sx={{ color: "rgba(255,255,255,0.4)", fontSize: 12 }}>{title}</Typography>
    </Paper>
  );
}