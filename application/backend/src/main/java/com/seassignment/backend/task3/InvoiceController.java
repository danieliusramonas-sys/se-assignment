package com.seassignment.backend.task3;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/task3")
public class InvoiceController {

    private final InvoiceService invoiceService;

    public InvoiceController(InvoiceService invoiceService) {
        this.invoiceService = invoiceService;
    }

    @GetMapping("/invoices")
    public List<InvoiceResult> findInvoices(
            @RequestParam(required = false) Long invoiceId,
            @RequestParam(required = false) String status
    ) {
        return invoiceService.findInvoices(invoiceId, status);
    }

    @GetMapping("/payments")
    public List<PaymentResult> findPayments(
            @RequestParam(required = false) Long invoiceId
    ) {
        return invoiceService.findPayments(invoiceId);
    }

    @PostMapping("/payments")
    public PaymentOperationResult addPayment(
            @RequestBody PaymentRequest request
    ) {
        return invoiceService.addPayment(request);
    }
}