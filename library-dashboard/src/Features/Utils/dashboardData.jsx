import {
  ResponsiveContainer,

  AreaChart,
  Area,
} from "recharts";
import PeopleAltOutlinedIcon from "@mui/icons-material/PeopleAltOutlined";
import MenuBookOutlinedIcon from "@mui/icons-material/MenuBookOutlined";
import AttachMoneyIcon from "@mui/icons-material/AttachMoney";
import CategoryOutlinedIcon from "@mui/icons-material/CategoryOutlined";
import {
  Box,

} from "@mui/material";
export const ADS = [
  {
    emoji: "📖",
    title: "Discover New Arrivals",
    desc: "Curated collection of newly added premium books",
  },
  {
    emoji: "🏆",
    title: "Reading Performance Boost",
    desc: "Engage users and unlock achievement-based rewards",
  },
  {
    emoji: "💡",
    title: "Smart Fee Optimization",
    desc: "Reduce overdue losses with automated discount campaigns",
  },
];

export const STAT_META = {
  Users:      { icon: <PeopleAltOutlinedIcon sx={{ fontSize: 16 }} />, accent: "#c9a84c", trend: "+12% this week" },
  Books:      { icon: <MenuBookOutlinedIcon  sx={{ fontSize: 16 }} />, accent: "#97c459", trend: "+8% this month" },
  Revenue:    { icon: <AttachMoneyIcon       sx={{ fontSize: 16 }} />, accent: "#1d9e75", trend: "+23% vs last month" },
  Categories: { icon: <CategoryOutlinedIcon  sx={{ fontSize: 16 }} />, accent: "#7f77dd", trend: "3 new added" },
};

const CHART_DATA = [8, 14, 10, 20, 26, 18, 30].map((v) => ({ v }));


export function MiniChart({ color }) {
  return (
    <Box sx={{ height: 32, mt: 1.5 }}>
      <ResponsiveContainer width="100%" height="100%">
        <AreaChart data={CHART_DATA}>
          <defs>
            <linearGradient id={`g${color.replace("#", "")}`} x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor={color} stopOpacity={0.25} />
              <stop offset="100%" stopColor={color} stopOpacity={0} />
            </linearGradient>
          </defs>
          <Area
            type="monotone"
            dataKey="v"
            stroke={color}
            strokeWidth={1.5}
            fill={`url(#g${color.replace("#", "")})`}
            dot={false}
          />
        </AreaChart>
      </ResponsiveContainer>
    </Box>
  );
}

export function WeeklyBar({ data, color }) {
  const max = Math.max(...data);
  return (
    <Box sx={{ display: "flex", alignItems: "flex-end", gap: "3px", height: 50, mt: 2.5 }}>
      {data.map((v, i) => (
        <Box
          key={i}
          sx={{
            flex: 1,
            borderRadius: "3px 3px 0 0",
            background: `linear-gradient(180deg, ${color}, ${color}30)`,
            height: `${Math.round((v / max) * 100)}%`,
            minHeight: 3,
            transition: "height 0.5s ease",
          }}
        />
      ))}
    </Box>
  );
}
