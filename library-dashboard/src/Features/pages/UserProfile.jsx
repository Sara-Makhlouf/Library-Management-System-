import { useEffect } from "react";
import { useParams } from "react-router-dom";
import { useUsers } from "../../Core/Context/UserContext";
import { Box, Typography, Card } from "@mui/material";

export default function UserProfilePage() {
  const { id } = useParams();
  const { selectedUser, getUser, loading } = useUsers();

  useEffect(() => {
    getUser(id);
  }, [getUser, id]);

  if (loading) return <p>Loading...</p>;

  if (!selectedUser) return <p>No user found</p>;

  return (
    <Box sx={{ p: 4 }}>
      <Typography fontSize={26} fontWeight={800} mb={3}>
        User Profile 👤
      </Typography>

      <Card sx={{ p: 3, borderRadius: 3 }}>
        <Typography fontWeight={700}>
          Name: {selectedUser.name}
        </Typography>

        <Typography>Email: {selectedUser.email}</Typography>
        <Typography>Role: {selectedUser.role}</Typography>
        <Typography>Status: {selectedUser.status}</Typography>
      </Card>
    </Box>
  );
}