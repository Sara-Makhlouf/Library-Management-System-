import React, { useMemo, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { COLORS } from "../Constants/ColorsUse";
import {
  CheckCircle,
  AlertTriangle,
  Info,
  XCircle,
  Eye,
  Search,
  Bell,
} from "lucide-react";
import "../CSS/Notification.css";
import Sidebar from "../Components/SideBar";
import '../CSS/SideBar.css';
export default function NotificationsPage() {
  const [filter, setFilter] = useState("all");
  const [search, setSearch] = useState("");
  const [notifications, setNotifications] = useState([
    {
      id: 1,
      title: "New Book Request",
      message: "A new request was submitted for 'Modern Web Architecture'.",
      time: "2 min ago",
      type: "info",
      unread: true,
    },
    {
      id: 2,
      title: "System Backup Completed",
      message: "Nightly backup finished successfully.",
      time: "18 min ago",
      type: "success",
      unread: true,
    },
    {
      id: 3,
      title: "Overdue Borrow Alert",
      message: "14 borrowed books are overdue.",
      time: "1 hour ago",
      type: "warning",
      unread: false,
    },
    {
      id: 4,
      title: "Failed Login Attempt",
      message: "A suspicious login attempt was detected.",
      time: "Today, 08:42",
      type: "danger",
      unread: false,
    },
  ]);

  const unreadCount = notifications.filter((n) => n.unread).length;

  const markAllAsRead = () => {
    setNotifications((prev) =>
      prev.map((item) => ({ ...item, unread: false }))
    );
  };

  const getIcon = (type) => {
    switch (type) {
      case "success":
        return <CheckCircle size={18} color="#16a34a" />;
      case "warning":
        return <AlertTriangle size={18} color="#d97706" />;
      case "danger":
        return <XCircle size={18} color="#dc2626" />;
      default:
        return <Info size={18} color="#2563eb" />;
    }
  };

  const getRowStyle = (type) => {
    switch (type) {
      case "success":
        return { backgroundColor: "#eefaf3", borderLeft: "4px solid #16a34a" };
      case "warning":
        return { backgroundColor: "#fff8e8", borderLeft: "4px solid #d97706" };
      case "danger":
        return { backgroundColor: "#fdeeee", borderLeft: "4px solid #dc2626" };
      default:
        return { backgroundColor: "#eef5ff", borderLeft: "4px solid #2563eb" };
    }
  };

  const filteredNotifications = useMemo(() => {
    return notifications.filter((item) => {
      const matchesFilter = filter === "all" || item.type === filter;
      const matchesSearch =
        item.title.toLowerCase().includes(search.toLowerCase()) ||
        item.message.toLowerCase().includes(search.toLowerCase());
      return matchesFilter && matchesSearch;
    });
  }, [notifications, filter, search]);

  return (
    <div
      style={{
        backgroundColor: COLORS.Background,
         flex: 1, padding: "30px", 
         marginLeft:"260px"
      }}
    >
      <Sidebar />

      <div style={{ flex: 1, padding: "30px" }}>
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            marginBottom: "24px",
            flexWrap: "wrap",
            gap: "16px",
          }}
        >
          <div>
            <h1 style={{ color: COLORS.Text, margin: 0, fontSize: "32px" }}>
              Notifications Center
            </h1>
            <p style={{ color: "#6b7280", marginTop: "8px" }}>
              Manage and filter system activities
            </p>
          </div>

          <button
            onClick={markAllAsRead}
            style={{
              backgroundColor: COLORS.Secondary,
              color: "#fff",
              border: "none",
              borderRadius: "12px",
              padding: "12px 18px",
              fontWeight: "600",
              cursor: "pointer",
              boxShadow: "0 8px 20px rgba(0,0,0,0.12)",
              transition: "0.3s",
            }}
          >
            Mark all as read
          </button>
        </div>

      
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))",
            gap: "18px",
            marginBottom: "28px",
          }}
        >
          <div
            style={{
              background: "#fff",
              borderRadius: "18px",
              padding: "20px",
              boxShadow: "0 10px 30px rgba(0,0,0,0.08)",
            }}
          >
            <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
              <Bell color={COLORS.Primary} />
              <div>
                <p style={{ margin: 0, color: "#6b7280" }}>Total Notifications</p>
                <h2 style={{ margin: "6px 0 0", color: COLORS.Text }}>
                  {notifications.length}
                </h2>
              </div>
            </div>
          </div>

          <div
            style={{
              background: "#fff",
              borderRadius: "18px",
              padding: "20px",
              boxShadow: "0 10px 30px rgba(0,0,0,0.08)",
            }}
          >
            <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
              <Info color="#2563eb" />
              <div>
                <p style={{ margin: 0, color: "#6b7280" }}>Unread Notifications</p>
                <h2 style={{ margin: "6px 0 0", color: COLORS.Text }}>
                  {unreadCount}
                </h2>
              </div>
            </div>
          </div>
        </div>

        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            flexWrap: "wrap",
            gap: "16px",
            marginBottom: "24px",
          }}
        >
          <div style={{ position: "relative", minWidth: "260px" }}>
            <Search
              size={18}
              style={{
                position: "absolute",
                left: "14px",
                top: "50%",
                transform: "translateY(-50%)",
                color: "#9ca3af",
              }}
            />
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search notifications..."
              style={{
                width: "100%",
                padding: "12px 14px 12px 42px",
                borderRadius: "12px",
                border: `1px solid ${COLORS.Accent}`,
                outline: "none",
                background: "#fff",
                boxShadow: "0 4px 12px rgba(0,0,0,0.05)",
              }}
            />
          </div>

          <div style={{ display: "flex", gap: "10px", flexWrap: "wrap" }}>
            {["all", "info", "success", "warning", "danger"].map((type) => (
              <button
                key={type}
                onClick={() => setFilter(type)}
                style={{
                  padding: "10px 16px",
                  borderRadius: "999px",
                  border: `1px solid ${COLORS.Primary}`,
                  cursor: "pointer",
                  backgroundColor: filter === type ? COLORS.Primary : "transparent",
                  color: filter === type ? "#fff" : COLORS.Text,
                  fontWeight: "600",
                  textTransform: "capitalize",
                  transition: "all 0.3s ease",
                }}
              >
                {type}
              </button>
            ))}
          </div>
        </div>

        <div
          style={{
            backgroundColor: "#fff",
            borderRadius: "20px",
            overflow: "hidden",
            boxShadow: "0 12px 35px rgba(0,0,0,0.08)",
          }}
        >
          <table
            style={{
              width: "100%",
              borderCollapse: "separate",
              borderSpacing: "0 10px",
              padding: "12px",
            }}
          >
            <thead>
              <tr>
                <th style={tableHead}>Status</th>
                <th style={tableHead}>Notification</th>
                <th style={tableHead}>Date / Time</th>
                <th style={tableHead}>Action</th>
              </tr>
            </thead>
            <tbody>
              <AnimatePresence>
                {filteredNotifications.map((item, index) => (
                  <motion.tr
                    key={item.id}
                    initial={{ opacity: 0, y: 12 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -12 }}
                    transition={{ duration: 0.25, delay: index * 0.05 }}
                    style={{
                      ...getRowStyle(item.type),
                      opacity: item.unread ? 1 : 0.7,
                      transition: "all 0.3s ease",
                    }}
                    whileHover={{
                      scale: 1.01,
                      boxShadow: "0 10px 20px rgba(0,0,0,0.08)",
                    }}
                  >
                    <td style={tableCellCenter}>{getIcon(item.type)}</td>
                    <td style={tableCell}>
                      <div
                        style={{
                          display: "flex",
                          alignItems: "center",
                          gap: "10px",
                          flexWrap: "wrap",
                        }}
                      >
                        <span style={{ fontWeight: "700", color: COLORS.Text, fontSize: "15px" }}>
                          {item.title}
                        </span>
                        {item.unread && (
                          <span
                            style={{
                              fontSize: "11px",
                              background: "linear-gradient(90deg, #ff7a18, #ff3d00)",
                              color: "#fff",
                              padding: "4px 9px",
                              borderRadius: "999px",
                              fontWeight: "600",
                            }}
                          >
                            New
                          </span>
                        )}
                      </div>
                      <p style={{ marginTop: "8px", marginBottom: 0, color: "#6b7280", fontSize: "13px" }}>
                        {item.message}
                      </p>
                    </td>
                    <td style={tableCell}>{item.time}</td>
                    <td style={tableCellCenter}>
                      <button
                        style={{
                          display: "flex",
                          alignItems: "center",
                          gap: "6px",
                          margin: "0 auto",
                          backgroundColor: "transparent",
                          border: `1px solid ${COLORS.Secondary}`,
                          color: COLORS.Secondary,
                          padding: "8px 14px",
                          borderRadius: "10px",
                          cursor: "pointer",
                          fontWeight: "600",
                          transition: "0.3s",
                        }}
                      >
                        <Eye size={14} />
                        View
                      </button>
                    </td>
                  </motion.tr>
                ))}
              </AnimatePresence>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

const tableHead = {
  padding: "18px",
  textAlign: "left",
  color: "#6b7280",
  fontWeight: "700",
  fontSize: "13px",
  textTransform: "uppercase",
};

const tableCell = {
  padding: "18px",
  color: "#374151",
};

const tableCellCenter = {
  ...tableCell,
  textAlign: "center",
};