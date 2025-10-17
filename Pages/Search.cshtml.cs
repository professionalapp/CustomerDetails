using Microsoft.AspNetCore.Mvc.RazorPages;
using CustomerDetails.Models;
using CustomerDetails.Data;

namespace CustomerDetails.Pages
{
    public class SearchModel : PageModel
    {
        public Customer? Customer { get; set; }
        public List<Transaction> Transactions { get; set; } = new List<Transaction>();
        public string SearchId { get; set; } = "";

        public void OnGet(string id)
        {
            SearchId = id;
            if (string.IsNullOrEmpty(id))
                return;

            // البحث عن العميل
            Customer = LocalDatabase.Customers.FirstOrDefault(c => c.Id == id);

            // جلب الحركات
            if (Customer != null)
            {
                Transactions = LocalDatabase.Transactions
                    .Where(t => t.CustomerId == id)
                    .OrderByDescending(t => t.Date)
                    .ToList();
            }
        }
    }
}
