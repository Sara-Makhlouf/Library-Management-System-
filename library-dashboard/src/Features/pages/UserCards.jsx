import { useEffect } from "react";
import { useUsers } from "../../Core/Context/UserContext";
import { Box, Card, Typography, Chip } from "@mui/material";

export default function UsersCardsPage() {
  const { users, getUsers, loading } = useUsers();

  useEffect(() => {
    getUsers();
  }, [getUsers]);

  if (loading) return <p>Loading...</p>;

  return (
    <Box sx={{ p: 4 }}>
      <Typography fontSize={26} fontWeight={800} mb={3}>
        Users Cards 🧑‍🤝‍🧑
      </Typography>

      <Box
        sx={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit,minmax(220px,1fr))",
          gap: 2,
        }}
      >
        {users.map((u) => (
          <Card
            key={u.id}
            sx={{
              p: 2,
              borderRadius: 3,
              textAlign: "center",
            }}
          >
            <Box
              sx={{
                width: 50,
                height: 50,
                borderRadius: "50%",
                bgcolor: "#c2a85a",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                mx: "auto",
                mb: 1,
                color: "#fff",
                fontWeight: 800,
              }}
            >
              {u.name?.charAt(0)}
            </Box>

            <Typography fontWeight={700}>{u.name}</Typography>
            <Typography fontSize={13} color="gray">
              {u.email}
            </Typography>

            <Chip
              label={u.role}
              size="small"
              sx={{ mt: 1 }}
            />
          </Card>
        ))}
      </Box>
    </Box>
  );
}