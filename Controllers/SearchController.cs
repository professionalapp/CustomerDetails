using Microsoft.AspNetCore.Mvc;
using CustomerDetails.Data;
using CustomerDetails.Models;

namespace CustomerDetails.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SearchController : ControllerBase
    {
        [HttpGet("customers")]
        public IActionResult SearchCustomers([FromQuery] string query)
        {
            if (string.IsNullOrWhiteSpace(query))
            {
                return Ok(new List<object>());
            }

            var results = LocalDatabase.Customers
                .Where(c => c.Name.Contains(query, StringComparison.OrdinalIgnoreCase) ||
                           c.Id.Contains(query, StringComparison.OrdinalIgnoreCase))
                .Take(10)
                .Select(c => new
                {
                    id = c.Id,
                    name = c.Name,
                    age = c.Age,
                    joinDate = c.JoinDate.ToString("yyyy/MM/dd")
                })
                .ToList();

            return Ok(results);
        }

        [HttpGet("customer/{id}")]
        public IActionResult GetCustomerById(string id)
        {
            var customer = LocalDatabase.Customers.FirstOrDefault(c => c.Id == id);

            if (customer == null)
            {
                return NotFound(new { message = "العميل غير موجود" });
            }

            var result = new
            {
                id = customer.Id,
                name = customer.Name,
                age = customer.Age,
                joinDate = customer.JoinDate.ToString("yyyy/MM/dd")
            };

            return Ok(result);
        }

        [HttpGet("transactions")]
        public IActionResult SearchTransactions([FromQuery] string query)
        {
            if (string.IsNullOrWhiteSpace(query))
            {
                return Ok(new List<object>());
            }

            var results = LocalDatabase.Transactions
                .Where(t => t.CustomerId.Contains(query, StringComparison.OrdinalIgnoreCase) ||
                           t.Type.Contains(query, StringComparison.OrdinalIgnoreCase))
                .Take(10)
                .Select(t => new
                {
                    customerId = t.CustomerId,
                    type = t.Type,
                    amount = t.Amount,
                    date = t.Date.ToString("yyyy/MM/dd")
                })
                .ToList();

            return Ok(results);
        }
    }
}
