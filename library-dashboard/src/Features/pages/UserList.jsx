import { useEffect } from "react";
import { useUsers } from "../../Core/Context/UserContext";
import { Box, Typography, Chip } from "@mui/material";

export default function UsersListPage() {
  const { users, getUsers, loading } = useUsers();

  useEffect(() => {
    getUsers();
  },);

  if (loading) return <p>Loading...</p>;

  return (
    <Box sx={{ p: 4 }}>
      <Typography fontSize={26} fontWeight={800} mb={3}>
        Users List 📋
      </Typography>

      {/* HEADER */}
      <Box
        sx={{
          display: "grid",
          gridTemplateColumns: "2fr 1fr 1fr 1fr",
          fontWeight: 700,
          mb: 2,
        }}
      >
        <span>Name</span>
        <span>Email</span>
        <span>Role</span>
        <span>Status</span>
      </Box>

      {/* ROWS */}
      {users.map((u) => (
        <Box
          key={u.id}
          sx={{
            display: "grid",
            gridTemplateColumns: "2fr 1fr 1fr 1fr",
            py: 2,
            borderBottom: "1px solid #eee",
          }}
        >
          <span>{u.name}</span>
          <span>{u.email}</span>
          <span>{u.role}</span>

          <Chip
            label={u.status}
            size="small"
            color={u.status === "Active" ? "success" : "error"}
          />
        </Box>
      ))}
    </Box>
  );
}