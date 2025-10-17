using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using CustomerDetails.Data;
using CustomerDetails.Models;

namespace CustomerDetails.Pages
{
    public class CustomerDetailsModel : PageModel
    {
        public Customer? Customer { get; set; }
        public List<Transaction> CustomerTransactions { get; set; } = new List<Transaction>();
        public double TotalDeposits { get; set; }
        public double TotalWithdrawals { get; set; }
        public double Balance { get; set; }

        public IActionResult OnGet(string id)
        {
            // البحث عن العميل
            Customer = LocalDatabase.Customers.FirstOrDefault(c => c.Id == id);

            if (Customer == null)
            {
                return NotFound();
            }

            // الحصول على معاملات العميل
            CustomerTransactions = LocalDatabase.Transactions
                .Where(t => t.CustomerId == id)
                .OrderByDescending(t => t.Date)
                .ToList();

            // حساب الإحصائيات
            TotalDeposits = CustomerTransactions
                .Where(t => t.Type == "إيداع")
                .Sum(t => t.Amount);

            TotalWithdrawals = CustomerTransactions
                .Where(t => t.Type == "سحب")
                .Sum(t => t.Amount);

            Balance = TotalDeposits - TotalWithdrawals;

            return Page();
        }
    }
}
