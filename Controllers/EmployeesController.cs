using Microsoft.AspNetCore.Mvc;
using Google.Cloud.Firestore;
using CustomerDetails.Models;

namespace CustomerDetails.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class EmployeesController : ControllerBase
    {
        private readonly FirestoreDb _db;
        private const string EmployeesCollection = "employees";
        private const string TransactionsCollection = "transactions";

        public EmployeesController(FirestoreDb db)
        {
            _db = db;
        }

        // CREATE employee
        [HttpPost]
        public async Task<IActionResult> CreateEmployee([FromBody] Employee body)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(body.EmployeeId) || string.IsNullOrWhiteSpace(body.Name))
                    return BadRequest(new { message = "EmployeeId و Name مطلوبان" });

                // التحقق من أن رقم العميل يحتوي على أرقام فقط
                if (!System.Text.RegularExpressions.Regex.IsMatch(body.EmployeeId, @"^[0-9]+$"))
                    return BadRequest(new { message = "رقم العميل يجب أن يحتوي على أرقام فقط" });

                // التحقق من أن الاسم يحتوي على أحرف عربية فقط
                if (!System.Text.RegularExpressions.Regex.IsMatch(body.Name, @"^[أ-ي\s]+$"))
                    return BadRequest(new { message = "الاسم يجب أن يحتوي على أحرف عربية فقط" });

                // التحقق من أن العمر يحتوي على أرقام فقط
                if (body.Age.ToString() != "" && !System.Text.RegularExpressions.Regex.IsMatch(body.Age.ToString(), @"^[0-9]+$"))
                    return BadRequest(new { message = "العمر يجب أن يحتوي على أرقام فقط" });

                var col = _db.Collection(EmployeesCollection);
                // enforce unique employeeId
                var existing = await col.WhereEqualTo("employeeId", body.EmployeeId).Limit(1).GetSnapshotAsync();
                if (existing.Any())
                    return Conflict(new { message = "يوجد عميل بنفس الرقم" });

                var doc = col.Document();
                body.CreatedAt ??= Timestamp.FromDateTime(DateTime.UtcNow);
                await doc.SetAsync(body);
                return Ok(new { id = body.EmployeeId, message = "تم إضافة العميل بنجاح" });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"خطأ في إضافة العميل: {ex.Message}");
                return StatusCode(500, new { message = "خطأ في الخادم: " + ex.Message });
            }
        }

        // UPDATE employee by employeeId
        [HttpPut("{employeeId}")]
        public async Task<IActionResult> UpdateEmployee(string employeeId, [FromBody] Employee body)
        {
            try
            {
                // التحقق من أن الاسم يحتوي على أحرف عربية فقط
                if (!string.IsNullOrWhiteSpace(body.Name) && !System.Text.RegularExpressions.Regex.IsMatch(body.Name, @"^[أ-ي\s]+$"))
                    return BadRequest(new { message = "الاسم يجب أن يحتوي على أحرف عربية فقط" });

                // التحقق من أن العمر يحتوي على أرقام فقط
                if (body.Age > 0 && !System.Text.RegularExpressions.Regex.IsMatch(body.Age.ToString(), @"^[0-9]+$"))
                    return BadRequest(new { message = "العمر يجب أن يحتوي على أرقام فقط" });

                var col = _db.Collection(EmployeesCollection);
                var snapshot = await col.WhereEqualTo("employeeId", employeeId).Limit(1).GetSnapshotAsync();
                var doc = snapshot.Documents.FirstOrDefault();
                if (doc == null) return NotFound(new { message = "العميل غير موجود" });

                var updates = new Dictionary<string, object?>
                {
                    ["name"] = body.Name,
                    ["age"] = body.Age,
                    ["address"] = body.Address,
                    ["identityName"] = body.IdentityName,
                    ["identityType"] = body.IdentityType,
                    ["imageUrl"] = body.ImageUrl,
                    ["updatedAt"] = Timestamp.FromDateTime(DateTime.UtcNow)
                };
                await doc.Reference.UpdateAsync(updates);
                return Ok(new { id = employeeId, message = "تم تحديث العميل بنجاح" });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"خطأ في تحديث العميل: {ex.Message}");
                return StatusCode(500, new { message = "خطأ في الخادم: " + ex.Message });
            }
        }

        // CREATE transaction for employeeId
        [HttpPost("{employeeId}/transactions")]
        public async Task<IActionResult> CreateTransaction(string employeeId, [FromBody] EmployeeTransaction tx)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(employeeId)) return BadRequest(new { message = "EmployeeId مطلوب" });
                if (tx.Amount == 0 || string.IsNullOrWhiteSpace(tx.TransactionType)) return BadRequest(new { message = "النوع والمبلغ مطلوبان" });

                // التحقق من أن المبلغ يحتوي على أرقام فقط
                if (!System.Text.RegularExpressions.Regex.IsMatch(tx.Amount.ToString(), @"^[0-9]+(\.[0-9]+)?$"))
                    return BadRequest(new { message = "المبلغ يجب أن يحتوي على أرقام فقط" });

                // التحقق من أن رقم الصندوق يحتوي على أرقام فقط (إذا كان موجوداً)
                if (!string.IsNullOrWhiteSpace(tx.BoxNumber) && !System.Text.RegularExpressions.Regex.IsMatch(tx.BoxNumber, @"^[0-9]+$"))
                    return BadRequest(new { message = "رقم الصندوق يجب أن يحتوي على أرقام فقط" });

                // ensure employee exists
                var empSnap = await _db.Collection(EmployeesCollection).WhereEqualTo("employeeId", employeeId).Limit(1).GetSnapshotAsync();
                if (!empSnap.Any()) return NotFound(new { message = "العميل غير موجود" });

                tx.EmployeeId = employeeId;
                tx.TransactionTime ??= Timestamp.FromDateTime(DateTime.UtcNow);
                tx.CreatedAt ??= Timestamp.FromDateTime(DateTime.UtcNow);
                await _db.Collection(TransactionsCollection).AddAsync(tx);
                return Ok(new { ok = true, message = "تم إضافة المعاملة بنجاح" });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"خطأ في إضافة المعاملة: {ex.Message}");
                return StatusCode(500, new { message = "خطأ في الخادم: " + ex.Message });
            }
        }

        [HttpGet]
        public async Task<IActionResult> GetAll([FromQuery] int limit = 200)
        {
            try
            {
                var snapshot = await _db.Collection(EmployeesCollection)
                    .OrderBy("name")
                    .Limit(limit)
                    .GetSnapshotAsync();

                var list = new List<object>();
                foreach (var doc in snapshot.Documents)
                {
                    if (!doc.Exists) continue;
                    try
                    {
                        var emp = doc.ConvertTo<Employee>();
                        list.Add(new
                        {
                            id = emp.EmployeeId,
                            name = emp.Name,
                            age = emp.Age,
                            createdAt = emp.CreatedAt?.ToDateTime().ToString("yyyy/MM/dd"),
                            address = emp.Address,
                            identityType = emp.IdentityType,
                            identityName = emp.IdentityName,
                            imageUrl = emp.ImageUrl
                        });
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"خطأ في تحويل المستند {doc.Id}: {ex.Message}");
                        // تخطي المستند المعطل والمتابعة
                        continue;
                    }
                }

                return Ok(list);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"خطأ في جلب بيانات العملاء: {ex.Message}");
                return StatusCode(500, new { message = "حدث خطأ أثناء تحميل بيانات العملاء", error = ex.Message });
            }
        }

        [HttpGet("search")]
        public async Task<IActionResult> Search([FromQuery] string query)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(query))
                {
                    return Ok(new List<object>());
                }

                var employeesCol = _db.Collection(EmployeesCollection);

                var nameTask = employeesCol
                    .WhereGreaterThanOrEqualTo("name", query)
                    .WhereLessThanOrEqualTo("name", query + "\uf8ff")
                    .Limit(10)
                    .GetSnapshotAsync();

                var idTask = employeesCol
                    .WhereGreaterThanOrEqualTo("employeeId", query)
                    .WhereLessThanOrEqualTo("employeeId", query + "\uf8ff")
                    .Limit(10)
                    .GetSnapshotAsync();

                await Task.WhenAll(nameTask, idTask);

                var docs = nameTask.Result.Documents.Concat(idTask.Result.Documents)
                    .GroupBy(d => d.Id)
                    .Select(g => g.First());

                var results = new List<object>();
                foreach (var doc in docs)
                {
                    if (!doc.Exists) continue;
                    try
                    {
                        var emp = doc.ConvertTo<Employee>();
                        results.Add(new
                        {
                            id = emp.EmployeeId,
                            name = emp.Name,
                            age = emp.Age,
                            joinDate = (emp.CreatedAt?.ToDateTime().ToString("yyyy/MM/dd")) ?? string.Empty
                        });
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"خطأ في تحويل المستند {doc.Id} أثناء البحث: {ex.Message}");
                        continue;
                    }
                }

                return Ok(results);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"خطأ في البحث: {ex.Message}");
                return StatusCode(500, new { message = "حدث خطأ أثناء البحث", error = ex.Message });
            }
        }

        [HttpGet("{employeeId}")]
        public async Task<IActionResult> GetByEmployeeId(string employeeId)
        {
            try
            {
                var snapshot = await _db.Collection(EmployeesCollection)
                    .WhereEqualTo("employeeId", employeeId)
                    .Limit(1)
                    .GetSnapshotAsync();

                var doc = snapshot.Documents.FirstOrDefault();
                if (doc == null || !doc.Exists)
                {
                    return NotFound(new { message = "العميل غير موجود" });
                }

                var emp = doc.ConvertTo<Employee>();
                return Ok(new
                {
                    id = emp.EmployeeId,
                    name = emp.Name,
                    age = emp.Age,
                    createdAt = emp.CreatedAt?.ToDateTime().ToString("yyyy/MM/dd"),
                    address = emp.Address,
                    identityName = emp.IdentityName,
                    identityType = emp.IdentityType,
                    imageUrl = emp.ImageUrl,
                    updatedAt = emp.UpdatedAt?.ToDateTime().ToString("yyyy/MM/dd HH:mm")
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"خطأ في جلب بيانات العميل {employeeId}: {ex.Message}");
                return StatusCode(500, new { message = "حدث خطأ أثناء تحميل بيانات العميل", error = ex.Message });
            }
        }

        [HttpGet("{employeeId}/transactions")]
        public async Task<IActionResult> GetTransactions(string employeeId, [FromQuery] int limit = 200)
        {
            try
            {
                var snapshot = await _db.Collection(TransactionsCollection)
                    .WhereEqualTo("employeeId", employeeId)
                    .Limit(limit)
                    .GetSnapshotAsync();

                var list = new List<EmployeeTransaction>();
                foreach (var doc in snapshot.Documents)
                {
                    if (!doc.Exists) continue;
                    try
                    {
                        var tr = doc.ConvertTo<EmployeeTransaction>();
                        tr.DocumentId = doc.Id; // Capture the Firestore document ID
                        list.Add(tr);
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"خطأ في تحويل المعاملة {doc.Id}: {ex.Message}");
                        continue;
                    }
                }

                var ordered = list
                    .OrderByDescending(t => t.TransactionTime?.ToDateTime().Ticks ?? t.CreatedAt?.ToDateTime().Ticks ?? 0)
                    .Select(tr => new
                    {
                        documentId = tr.DocumentId, // Return the document ID
                        employeeId = tr.EmployeeId,
                        amount = tr.Amount,
                        transactionType = tr.TransactionType,
                        transactionTime = tr.TransactionTime?.ToDateTime().ToString("yyyy/MM/dd HH:mm") ?? tr.CreatedAt?.ToDateTime().ToString("yyyy/MM/dd HH:mm"),
                        boxNumber = tr.BoxNumber,
                        description = tr.Description
                    })
                    .ToList();

                return Ok(ordered);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"خطأ في جلب معاملات العميل {employeeId}: {ex.Message}");
                return StatusCode(500, new { message = "حدث خطأ أثناء تحميل معاملات العميل", error = ex.Message });
            }
        }

        // GET single transaction by documentId
        [HttpGet("{employeeId}/transactions/{transactionId}")]
        public async Task<IActionResult> GetTransactionById(string employeeId, string transactionId)
        {
            var docSnapshot = await _db.Collection(TransactionsCollection).Document(transactionId).GetSnapshotAsync();
            if (!docSnapshot.Exists) return NotFound(new { message = "المعاملة غير موجودة" });

            var tr = docSnapshot.ConvertTo<EmployeeTransaction>();
            tr.DocumentId = docSnapshot.Id;

            // Optional: Verify employeeId matches the transaction's employeeId
            if (tr.EmployeeId != employeeId) return Unauthorized(new { message = "المعاملة لا تنتمي لهذا العميل" });

            return Ok(new
            {
                documentId = tr.DocumentId,
                employeeId = tr.EmployeeId,
                amount = tr.Amount,
                transactionType = tr.TransactionType,
                transactionTime = tr.TransactionTime?.ToDateTime().ToString("yyyy/MM/dd HH:mm") ?? tr.CreatedAt?.ToDateTime().ToString("yyyy/MM/dd HH:mm"),
                boxNumber = tr.BoxNumber,
                description = tr.Description
            });
        }

        // UPDATE transaction by documentId
        [HttpPut("{employeeId}/transactions/{transactionId}")]
        public async Task<IActionResult> UpdateTransaction(string employeeId, string transactionId, [FromBody] EmployeeTransaction body)
        {
            try
            {
                // التحقق من أن المبلغ يحتوي على أرقام فقط
                if (!System.Text.RegularExpressions.Regex.IsMatch(body.Amount.ToString(), @"^[0-9]+(\.[0-9]+)?$"))
                    return BadRequest(new { message = "المبلغ يجب أن يحتوي على أرقام فقط" });

                // التحقق من أن رقم الصندوق يحتوي على أرقام فقط (إذا كان موجوداً)
                if (!string.IsNullOrWhiteSpace(body.BoxNumber) && !System.Text.RegularExpressions.Regex.IsMatch(body.BoxNumber, @"^[0-9]+$"))
                    return BadRequest(new { message = "رقم الصندوق يجب أن يحتوي على أرقام فقط" });

                var docRef = _db.Collection(TransactionsCollection).Document(transactionId);
                var docSnapshot = await docRef.GetSnapshotAsync();
                if (!docSnapshot.Exists) return NotFound(new { message = "المعاملة غير موجودة" });

                var updates = new Dictionary<string, object?>
                {
                    ["amount"] = body.Amount,
                    ["transactionType"] = body.TransactionType,
                    ["boxNumber"] = body.BoxNumber,
                    ["description"] = body.Description,
                    ["transactionTime"] = body.TransactionTime ?? Timestamp.FromDateTime(DateTime.UtcNow) // Allow updating time if provided, otherwise keep existing or default
                };

                // Do not allow changing employeeId via transaction update for simplicity

                await docRef.UpdateAsync(updates);
                return Ok(new { ok = true, message = "تم تحديث المعاملة بنجاح" });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"خطأ في تحديث المعاملة: {ex.Message}");
                return StatusCode(500, new { message = "خطأ في الخادم: " + ex.Message });
            }
        }
    }
}
