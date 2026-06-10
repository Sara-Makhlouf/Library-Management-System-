import api from "../../Api/aixos";
import { createApiThunk } from "../utils/reduxHelpers";

export const fetchUsers = createApiThunk("user/fetchUsers", async () => {
  const response = await api.get("/admin/users");
  return response.data;
});

export default fetchUsers;

export const deletUsers = createApiThunk(
  "user/deletUsers",
  async (userId) => {
    const response = await api.delete("/admin/users/" + userId);
    return response.data;
  }
);

export const fetchUserWithDetails = createApiThunk(
  "user/fetchUserWithDetails",
  async (userId) => {
    const response = await api.get("/admin/users/" + userId);
    return response.data;
  }
);

export const getAllOperationForUser = createApiThunk(
  "user/getAllOperationForUser",
  async (userId) => {
    const response = await api.get(
      "/admin/users/" + userId + "/full-details"
    );
    return response.data;
  }
);
