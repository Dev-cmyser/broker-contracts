type User = {
  firstName: string;
  lastName: string;
  age?: number;
  details: {
    address: {
      street: string;
      city: string;
      zipCode: string;
      country: string;
    };
    contact: {
      email?: string;
      phoneNumber: string;
    };
    profile: {
      companyName: string;
      position?: string;
    };
  };
};
