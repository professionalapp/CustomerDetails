using System.Net.Http;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace CustomerDetails.Pages
{
    public class UsersModel : PageModel
    {
        private readonly IHttpClientFactory _httpClientFactory;

        public UsersModel(IHttpClientFactory httpClientFactory)
        {
            _httpClientFactory = httpClientFactory;
        }

        [BindProperty(SupportsGet = true)]
        public string? Query { get; set; }

        public List<UserDto> Users { get; private set; } = new List<UserDto>();

        public string? ErrorMessage { get; private set; }

        public async Task OnGet()
        {
            try
            {
                var client = _httpClientFactory.CreateClient();
                var allUsers = await client.GetFromJsonAsync<List<UserDto>>("https://jsonplaceholder.typicode.com/users");

                if (allUsers == null)
                {
                    Users = new List<UserDto>();
                    return;
                }

                if (string.IsNullOrWhiteSpace(Query))
                {
                    Users = allUsers;
                }
                else
                {
                    var q = Query.Trim();
                    bool Contains(string? s) => !string.IsNullOrWhiteSpace(s) && s.Contains(q, StringComparison.OrdinalIgnoreCase);

                    Users = allUsers.Where(u =>
                        Contains(u.Name) ||
                        Contains(u.Username) ||
                        Contains(u.Email) ||
                        Contains(u.Phone) ||
                        Contains(u.Website) ||
                        Contains(u.Company?.Name) ||
                        Contains(u.Address?.City) ||
                        Contains(u.Address?.Street) ||
                        Contains(u.Address?.Suite)
                    ).ToList();
                }
            }
            catch (Exception ex)
            {
                ErrorMessage = $"تعذر جلب البيانات من API: {ex.Message}";
            }
        }

        public class UserDto
        {
            public int Id { get; set; }
            public string? Name { get; set; }
            public string? Username { get; set; }
            public string? Email { get; set; }
            public AddressDto? Address { get; set; }
            public string? Phone { get; set; }
            public string? Website { get; set; }
            public CompanyDto? Company { get; set; }
        }

        public class AddressDto
        {
            public string? Street { get; set; }
            public string? Suite { get; set; }
            public string? City { get; set; }
            public string? Zipcode { get; set; }
            public GeoDto? Geo { get; set; }
        }

        public class GeoDto
        {
            public string? Lat { get; set; }
            public string? Lng { get; set; }
        }

        public class CompanyDto
        {
            public string? Name { get; set; }
            public string? CatchPhrase { get; set; }
            public string? Bs { get; set; }
        }
    }
}


