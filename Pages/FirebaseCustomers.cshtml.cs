using Microsoft.AspNetCore.Mvc.RazorPages;
using CustomerDetails.Models;
using Google.Cloud.Firestore;

namespace CustomerDetails.Pages
{
    public class FirebaseCustomersModel : PageModel
    {
        private readonly FirestoreDb _firestoreDb;
        public List<Customer> FirebaseCustomers { get; set; } = new List<Customer>();

        public FirebaseCustomersModel(FirestoreDb firestoreDb)
        {
            _firestoreDb = firestoreDb;
        }

        public async Task OnGetAsync()
        {
            CollectionReference customersRef = _firestoreDb.Collection("Customers");
            QuerySnapshot snapshot = await customersRef.GetSnapshotAsync();
            foreach (DocumentSnapshot document in snapshot.Documents)
            {
                if (document.Exists)
                {
                    Customer customer = document.ConvertTo<Customer>();
                    FirebaseCustomers.Add(customer);
                }
            }
        }
    }
}
