import { faker } from '@faker-js/faker';
import { TestPersona } from '../types';

export class PersonaGenerator {
  private spanishLocale = 'es';
  private englishLocale = 'en';
  
  /**
   * Generate realistic personas with cultural diversity
   */
  generatePersonas(
    count: number, 
    tenantId: string, 
    language: 'en' | 'es' | 'mixed' = 'mixed'
  ): TestPersona[] {
    const personas: TestPersona[] = [];
    
    for (let i = 0; i < count; i++) {
      const personaLanguage = this.determineLanguage(language);
      const persona = this.generateSinglePersona(tenantId, personaLanguage);
      personas.push(persona);
    }
    
    return personas;
  }

  private generateSinglePersona(tenantId: string, language: 'en' | 'es'): TestPersona {
    // Note: Modern faker.js uses locales differently - we'll handle this in individual methods

    const firstName = this.generateFirstName(language);
    const lastName = this.generateLastName(language);
    const email = this.generateRealisticEmail(firstName, lastName);
    const phone = this.generatePhone(language);
    
    const persona: TestPersona = {
      tenant_id: tenantId,
      first_name: firstName,
      last_name: lastName,
      email: email,
      phone: phone,
      date_of_birth: this.generateBirthDate(),
      language_preference: language,
      timezone: this.generateTimezone(language),
      profile_picture_url: this.generateProfilePicture(),
      created_at: this.generateCreatedDate(),
      updated_at: new Date()
    };
    
    return persona;
  }

  private generateFirstName(language: 'en' | 'es'): string {
    if (language === 'es') {
      // Common Spanish first names
      const maleNames = [
        'José', 'Antonio', 'Manuel', 'Francisco', 'Juan', 'David', 'José Antonio',
        'José Luis', 'Jesús', 'Javier', 'Carlos', 'Miguel', 'Alejandro', 'Rafael',
        'Fernando', 'Daniel', 'Jorge', 'Ricardo', 'Santiago', 'Eduardo'
      ];
      const femaleNames = [
        'María', 'Carmen', 'Josefa', 'Isabel', 'Ana María', 'María del Carmen',
        'Dolores', 'Pilar', 'María Teresa', 'Ana', 'Francisca', 'Laura',
        'Antonia', 'Mercedes', 'Elena', 'Rosa', 'Cristina', 'Paula', 'Beatriz', 'Lucía'
      ];
      
      const names = faker.helpers.arrayElement([maleNames, femaleNames]);
      return faker.helpers.arrayElement(names);
    } else {
      return faker.person.firstName();
    }
  }

  private generateLastName(language: 'en' | 'es'): string {
    if (language === 'es') {
      // Common Spanish surnames
      const surnames = [
        'García', 'Rodríguez', 'González', 'Fernández', 'López', 'Martínez',
        'Sánchez', 'Pérez', 'Gómez', 'Martín', 'Jiménez', 'Ruiz', 'Hernández',
        'Díaz', 'Moreno', 'Muñoz', 'Álvarez', 'Romero', 'Alonso', 'Gutiérrez',
        'Navarro', 'Torres', 'Domínguez', 'Vázquez', 'Ramos', 'Gil', 'Ramírez',
        'Serrano', 'Blanco', 'Suárez', 'Molina', 'Morales', 'Ortega', 'Delgado'
      ];
      
      // Spanish naming convention: often two surnames
      const firstSurname = faker.helpers.arrayElement(surnames);
      const secondSurname = faker.helpers.arrayElement(surnames);
      
      return faker.datatype.boolean(0.7) ? `${firstSurname} ${secondSurname}` : firstSurname;
    } else {
      return faker.person.lastName();
    }
  }

  private generateRealisticEmail(firstName: string, lastName: string): string {
    // Clean names for email generation - remove all non-alphanumeric characters
    const cleanFirst = firstName.toLowerCase()
      .replace(/\s+/g, '')
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '') // Remove accents
      .replace(/[^a-z0-9]/g, ''); // Remove any remaining non-alphanumeric characters
    
    const cleanLast = lastName.toLowerCase()
      .replace(/\s+/g, '')
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '') // Remove accents
      .replace(/[^a-z0-9]/g, ''); // Remove any remaining non-alphanumeric characters

    // Email providers with appropriate distribution
    const providers = [
      { value: { domain: 'gmail.com' }, weight: 40 },
      { value: { domain: 'yahoo.com' }, weight: 15 },
      { value: { domain: 'hotmail.com' }, weight: 10 },
      { value: { domain: 'outlook.com' }, weight: 10 },
      { value: { domain: 'icloud.com' }, weight: 8 },
      { value: { domain: 'aol.com' }, weight: 5 },
      { value: { domain: 'protonmail.com' }, weight: 3 },
      { value: { domain: 'company.com' }, weight: 9 } // Work emails
    ];

    const provider = faker.helpers.weightedArrayElement(providers) as { domain: string };
    const emailFormats = [
      `${cleanFirst}.${cleanLast}`,
      `${cleanFirst}${cleanLast}`,
      `${cleanFirst}${cleanLast.charAt(0)}`,
      `${cleanFirst.charAt(0)}${cleanLast}`,
      `${cleanFirst}${faker.number.int({ min: 1, max: 999 })}`,
      `${cleanFirst}.${cleanLast}${faker.number.int({ min: 1, max: 99 })}`
    ];

    const emailLocal = faker.helpers.arrayElement(emailFormats);
    return `${emailLocal}@${provider.domain}`;
  }

  private generatePhone(language: 'en' | 'es'): string {
    if (language === 'es') {
      // US Spanish speakers often use US phone numbers
      return faker.phone.number('###-###-####');
    } else {
      return faker.phone.number('###-###-####');
    }
  }

  private generateBirthDate(): Date {
    // Generate realistic age distribution for inheritance planning
    const ageDistribution = [
      { value: { min: 18, max: 30 }, weight: 15 }, // Young adults
      { value: { min: 30, max: 45 }, weight: 25 }, // Early career
      { value: { min: 45, max: 60 }, weight: 35 }, // Peak earning years
      { value: { min: 60, max: 80 }, weight: 20 }, // Pre/early retirement
      { value: { min: 80, max: 95 }, weight: 5 }   // Elderly
    ];

    const ageRange = faker.helpers.weightedArrayElement(ageDistribution) as { min: number, max: number };
    return faker.date.birthdate({ min: ageRange.min, max: ageRange.max });
  }

  private generateTimezone(language: 'en' | 'es'): string {
    if (language === 'es') {
      // US Spanish speakers concentrated in certain regions
      const spanishTimezones = [
        'America/Los_Angeles',    // California - 32% of Hispanic population
        'America/Phoenix',        // Arizona
        'America/Denver',         // Mountain time
        'America/Chicago',        // Texas, Illinois - 30% of Hispanic population
        'America/New_York'        // Florida, New York - 25% of Hispanic population
      ];
      return faker.helpers.weightedArrayElement([
        { value: 'America/Los_Angeles', weight: 25 },
        { value: 'America/Chicago', weight: 25 },
        { value: 'America/New_York', weight: 20 },
        { value: 'America/Phoenix', weight: 15 },
        { value: 'America/Denver', weight: 15 }
      ]);
    } else {
      // Standard US timezone distribution
      return faker.helpers.weightedArrayElement([
        { value: 'America/New_York', weight: 35 },
        { value: 'America/Chicago', weight: 25 },
        { value: 'America/Denver', weight: 15 },
        { value: 'America/Los_Angeles', weight: 20 },
        { value: 'America/Anchorage', weight: 3 },
        { value: 'Pacific/Honolulu', weight: 2 }
      ]);
    }
  }

  private generateProfilePicture(): string | undefined {
    // 70% of users have profile pictures
    if (faker.datatype.boolean(0.7)) {
      return `https://api.dicebear.com/7.x/avataaars/svg?seed=${faker.string.alphanumeric(10)}`;
    }
    return undefined;
  }

  private generateCreatedDate(): Date {
    // Account creation over the past 2 years with recent bias
    return faker.date.between({ 
      from: new Date(Date.now() - 2 * 365 * 24 * 60 * 60 * 1000),
      to: new Date()
    });
  }

  private determineLanguage(preference: 'en' | 'es' | 'mixed'): 'en' | 'es' {
    if (preference === 'mixed') {
      // 15% Spanish, 85% English (US demographics)
      return faker.datatype.boolean(0.15) ? 'es' : 'en';
    }
    return preference;
  }

  /**
   * Generate family relationships - useful for creating realistic FFCs
   */
  generateFamilyGroup(
    size: number, 
    tenantId: string, 
    language: 'en' | 'es' | 'mixed' = 'mixed'
  ): { 
    patriarch?: TestPersona, 
    matriarch?: TestPersona, 
    children: TestPersona[], 
    spouses: TestPersona[],
    grandchildren: TestPersona[]
  } {
    const familyLanguage = this.determineLanguage(language);
    
    // Generate consistent family surname
    const familySurname = this.generateLastName(familyLanguage);
    
    const patriarch = this.generatePatriarch(tenantId, familySurname, familyLanguage);
    const matriarch = this.generateMatriarch(tenantId, familySurname, familyLanguage);
    
    const numChildren = faker.number.int({ min: 1, max: 5 });
    const children = this.generateChildren(numChildren, tenantId, familySurname, familyLanguage);
    
    // Some children have spouses
    const spouses = this.generateSpouses(children, tenantId, familyLanguage);
    
    // Some couples have children (grandchildren)
    const grandchildren = this.generateGrandchildren(children, spouses, tenantId, familyLanguage);

    return { patriarch, matriarch, children, spouses, grandchildren };
  }

  private generatePatriarch(tenantId: string, surname: string, language: 'en' | 'es'): TestPersona {
    const firstName = this.generateFirstName(language);
    return {
      ...this.generateSinglePersona(tenantId, language),
      first_name: firstName,
      last_name: surname,
      date_of_birth: faker.date.birthdate({ min: 55, max: 85 })
    };
  }

  private generateMatriarch(tenantId: string, surname: string, language: 'en' | 'es'): TestPersona {
    const firstName = this.generateFirstName(language);
    return {
      ...this.generateSinglePersona(tenantId, language),
      first_name: firstName,
      last_name: surname,
      date_of_birth: faker.date.birthdate({ min: 50, max: 80 })
    };
  }

  private generateChildren(count: number, tenantId: string, familySurname: string, language: 'en' | 'es'): TestPersona[] {
    return Array.from({ length: count }, () => {
      const firstName = this.generateFirstName(language);
      return {
        ...this.generateSinglePersona(tenantId, language),
        first_name: firstName,
        last_name: familySurname,
        date_of_birth: faker.date.birthdate({ min: 25, max: 55 })
      };
    });
  }

  private generateSpouses(children: TestPersona[], tenantId: string, language: 'en' | 'es'): TestPersona[] {
    return children
      .filter(() => faker.datatype.boolean(0.6)) // 60% of children have spouses
      .map(() => this.generateSinglePersona(tenantId, language));
  }

  private generateGrandchildren(
    children: TestPersona[], 
    spouses: TestPersona[], 
    tenantId: string, 
    language: 'en' | 'es'
  ): TestPersona[] {
    const grandchildren: TestPersona[] = [];
    const couplesWithChildren = Math.min(children.length, spouses.length);
    
    for (let i = 0; i < couplesWithChildren; i++) {
      if (faker.datatype.boolean(0.7)) { // 70% of couples have children
        const numGrandchildren = faker.number.int({ min: 1, max: 3 });
        for (let j = 0; j < numGrandchildren; j++) {
          const grandchild = {
            ...this.generateSinglePersona(tenantId, language),
            last_name: children[i].last_name,
            date_of_birth: faker.date.birthdate({ min: 1, max: 25 })
          };
          grandchildren.push(grandchild);
        }
      }
    }
    
    return grandchildren;
  }
}