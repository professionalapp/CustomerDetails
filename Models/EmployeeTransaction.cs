using Google.Cloud.Firestore;

namespace CustomerDetails.Models
{
    [FirestoreData]
    public class EmployeeTransaction
    {
        [FirestoreProperty("employeeId")] public string EmployeeId { get; set; } = string.Empty;
        [FirestoreProperty("amount")] public double Amount { get; set; }
        [FirestoreProperty("transactionType")] public string TransactionType { get; set; } = string.Empty; // "إيداع" أو "سحب" أو غيره
        [FirestoreProperty("transactionTime")] public Timestamp? TransactionTime { get; set; }
        [FirestoreProperty("boxNumber")] public string? BoxNumber { get; set; }
        [FirestoreProperty("description")] public string? Description { get; set; }
        [FirestoreProperty("createdAt")] public Timestamp? CreatedAt { get; set; }
        [FirestoreDocumentId] public string DocumentId { get; set; } = string.Empty; // Add this for updates
    }
}
