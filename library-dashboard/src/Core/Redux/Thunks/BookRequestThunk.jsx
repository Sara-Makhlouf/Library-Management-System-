import axios from "axios";
import { getAuthConfig } from "../../Api/aixos";
import { createApiThunk } from "../utils/reduxHelpers";

export const updateBookRequestStatus = createApiThunk(
  "adminBookRequests/updateBookRequestStatus",
  async ({ requestId, status, admin_note }) => {
    const response = await axios.put(
      `/admin/book-requests/${requestId}/status`,
      { status, admin_note },
      getAuthConfig()
    );
    return response.data;
  }
);
