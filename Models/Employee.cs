using Google.Cloud.Firestore;

namespace CustomerDetails.Models
{
    [FirestoreData]
    public class Employee
    {
        [FirestoreProperty("employeeId")]
        public string EmployeeId { get; set; } = string.Empty;

        [FirestoreProperty("name")]
        public string Name { get; set; } = string.Empty;

        [FirestoreProperty("age")]
        public int Age { get; set; }

        [FirestoreProperty("createdAt")]
        public Timestamp? CreatedAt { get; set; }

        [FirestoreProperty("updatedAt")]
        public Timestamp? UpdatedAt { get; set; }

        [FirestoreProperty("address")]
        public string? Address { get; set; }

        [FirestoreProperty("identityName")]
        public string? IdentityName { get; set; }

        [FirestoreProperty("identityType")]
        public string? IdentityType { get; set; }

        [FirestoreProperty("imageUrl")]
        public string? ImageUrl { get; set; }
    }
}

