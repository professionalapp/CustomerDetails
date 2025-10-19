using Microsoft.AspNetCore.Mvc.RazorPages;
using CustomerDetails.Data;
using CustomerDetails.Models;

namespace CustomerDetails.Pages
{
    public class HomeModel : PageModel
    {
        public List<Customer> Customers { get; set; } = new List<Customer>();
        public List<Transaction> Transactions { get; set; } = new List<Transaction>();

        public void OnGet()
        {
            Customers = LocalDatabase.Customers;
            Transactions = LocalDatabase.Transactions;
        }
    }
}

