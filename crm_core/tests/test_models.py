from django.test import TestCase

from crm_core.models import Customer


class CustomerTestCase(TestCase):
    fixtures = ['core_data', ]

    def setUp(self):
        pass

    def tearDown(self):
        pass

    def test_get_customer(self):
        customer = Customer.objects.get(pk=1)
        self.assertEqual(customer.firstname, 'Honesto')

'''    def test_get_absolute_url(self):
        customer = Customer.objects.get(pk=1)
        data = str(customer.get_absolute_url)
        self.assertEqual(data, 'Mr Honesto Comerciante')'''
