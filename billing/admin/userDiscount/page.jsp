<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*" %>
<jsp:useBean id="userBn" class="user.userBean" />
<%
Integer uid = (Integer) session.getAttribute("userId");
if (uid == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
Vector userList = userBn.getAllUsersWithDiscount();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>User Discount</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container mt-4">
        <h3 class="mb-4"><i class="fas fa-percent me-2"></i>User Discount</h3>

        <!-- Alert placeholder for action feedback -->
        <div id="alertBox"></div>

        <div class="card shadow-sm">
            <div class="card-body p-0">
                <table class="table table-hover table-bordered mb-0">
                    <thead>
                        <tr style="background:linear-gradient(135deg,#f7fafc,#edf2f7);border-bottom:2px solid #e2e8f0;">
                            <th style="width:5%;font-size:.85rem;color:#4a5568;">#</th>
                            <th style="font-size:.85rem;color:#4a5568;">Username</th>
                            <th style="font-size:.85rem;color:#4a5568;">Full Name</th>
                            <th style="font-size:.85rem;color:#4a5568;text-align:center;">Discount %</th>
                            <th style="font-size:.85rem;color:#4a5568;text-align:center;">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                    if (userList != null && !userList.isEmpty()) {
                        for (int i = 0; i < userList.size(); i++) {
                            Vector row = (Vector) userList.get(i);
                            int    userId   = (Integer) row.elementAt(0);
                            String userName = row.elementAt(1).toString();
                            String fullName = row.elementAt(2).toString();
                            int    discPer  = (Integer) row.elementAt(3);
                    %>
                    <tr>
                        <td><%=i+1%></td>
                        <td><%=userName%></td>
                        <td><%=fullName.isEmpty() ? "-" : fullName%></td>
                        <td style="text-align:center;">
                            <span class="badge bg-primary fs-6"><%=discPer%>%</span>
                        </td>
                        <td style="text-align:center;">
                            <button class="btn btn-sm btn-outline-primary"
                                    onclick="openDiscountModal(<%=userId%>, '<%=userName.replace("'","\\\'")%>', '<%=fullName.isEmpty()?"-":fullName.replace("'","\\\'")%>', <%=discPer%>)">
                                <i class="fas fa-edit me-1"></i>Edit
                            </button>
                        </td>
                    </tr>
                    <%
                        }
                    } else {
                    %>
                    <tr><td colspan="5" class="text-center text-muted py-3">No users found.</td></tr>
                    <%
                    }
                    %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Edit Discount Modal -->
    <div class="modal fade" id="discountModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-sm">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title"><i class="fas fa-percent me-2"></i>Edit Discount</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="modalUserId">

                    <div class="mb-2">
                        <span class="fw-bold" id="modalUserLabel"></span>
                    </div>

                    <table class="table table-sm table-bordered mb-3">
                        <tr>
                            <th class="table-light">Current Discount</th>
                            <td><span id="modalOldDisc" class="badge bg-secondary fs-6"></span></td>
                        </tr>
                    </table>

                    <div class="mb-3">
                        <label class="form-label fw-bold">New Discount %</label>
                        <div class="input-group">
                            <input type="number" id="modalNewDisc" class="form-control"
                                   min="0" max="100" step="1" placeholder="0 – 100">
                            <span class="input-group-text">%</span>
                        </div>
                        <div class="form-text text-muted">Enter a value between 0 and 100.</div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                        <i class="fas fa-times me-1"></i>Cancel
                    </button>
                    <button type="button" class="btn btn-primary" onclick="saveDiscount()">
                        <i class="fas fa-save me-1"></i>Update
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script>
    function openDiscountModal(userId, userName, fullName, currentDisc) {
        document.getElementById('modalUserId').value   = userId;
        document.getElementById('modalUserLabel').textContent =
            fullName !== '-' ? fullName + ' (' + userName + ')' : userName;
        document.getElementById('modalOldDisc').textContent  = currentDisc + '%';
        document.getElementById('modalNewDisc').value        = currentDisc;
        new bootstrap.Modal(document.getElementById('discountModal')).show();
        setTimeout(function(){ document.getElementById('modalNewDisc').select(); }, 400);
    }

    function saveDiscount() {
        var userId  = document.getElementById('modalUserId').value;
        var newDisc = parseInt(document.getElementById('modalNewDisc').value);

        if (isNaN(newDisc) || newDisc < 0 || newDisc > 100) {
            Swal.fire({ icon: 'error', title: 'Invalid', text: 'Discount must be between 0 and 100.' });
            return;
        }

        $.ajax({
            url: 'updateUserDiscount.jsp',
            type: 'POST',
            data: { userId: userId, discPer: newDisc },
            success: function(res) {
                res = res.trim();
                if (res === 'OK') {
                    bootstrap.Modal.getInstance(document.getElementById('discountModal')).hide();
                    Swal.fire({
                        icon: 'success', title: 'Updated',
                        text: 'Discount updated successfully.',
                        timer: 1500, showConfirmButton: false
                    }).then(function(){ location.reload(); });
                } else {
                    Swal.fire({ icon: 'error', title: 'Error', text: res });
                }
            },
            error: function() {
                Swal.fire({ icon: 'error', title: 'Error', text: 'Failed to update. Please try again.' });
            }
        });
    }

    document.getElementById('modalNewDisc').addEventListener('keypress', function(e){
        if (e.key === 'Enter') saveDiscount();
    });
    </script>
</body>
</html>
