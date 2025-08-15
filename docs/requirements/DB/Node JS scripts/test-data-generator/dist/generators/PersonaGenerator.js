"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PersonaGenerator = void 0;
const faker_1 = require("@faker-js/faker");
class PersonaGenerator {
    spanishLocale = 'es';
    englishLocale = 'en';
    /**
     * Generate realistic personas with cultural diversity
     */
    generatePersonas(count, tenantId, language = 'mixed') {
        const personas = [];
        for (let i = 0; i < count; i++) {
            const personaLanguage = this.determineLanguage(language);
            const persona = this.generateSinglePersona(tenantId, personaLanguage);
            personas.push(persona);
        }
        return personas;
    }
    generateSinglePersona(tenantId, language) {
        // Note: Modern faker.js uses locales differently - we'll handle this in individual methods
        const firstName = this.generateFirstName(language);
        const lastName = this.generateLastName(language);
        const email = this.generateRealisticEmail(firstName, lastName);
        const phone = this.generatePhone(language);
        const persona = {
            tenant_id: tenantId,
            first_name: firstName,
            last_name: lastName,
            date_of_birth: this.generateBirthDate(),
            is_living: true,
            status: 'active',
            language_preference: language,
            created_at: this.generateCreatedDate(),
            updated_at: new Date()
        };
        return persona;
    }
    generateFirstName(language) {
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
            const names = faker_1.faker.helpers.arrayElement([maleNames, femaleNames]);
            return faker_1.faker.helpers.arrayElement(names);
        }
        else {
            return faker_1.faker.person.firstName();
        }
    }
    generateLastName(language) {
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
            const firstSurname = faker_1.faker.helpers.arrayElement(surnames);
            const secondSurname = faker_1.faker.helpers.arrayElement(surnames);
            return faker_1.faker.datatype.boolean(0.7) ? `${firstSurname} ${secondSurname}` : firstSurname;
        }
        else {
            return faker_1.faker.person.lastName();
        }
    }
    generateRealisticEmail(firstName, lastName) {
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
        const provider = faker_1.faker.helpers.weightedArrayElement(providers);
        const emailFormats = [
            `${cleanFirst}.${cleanLast}`,
            `${cleanFirst}${cleanLast}`,
            `${cleanFirst}${cleanLast.charAt(0)}`,
            `${cleanFirst.charAt(0)}${cleanLast}`,
            `${cleanFirst}${faker_1.faker.number.int({ min: 1, max: 999 })}`,
            `${cleanFirst}.${cleanLast}${faker_1.faker.number.int({ min: 1, max: 99 })}`
        ];
        const emailLocal = faker_1.faker.helpers.arrayElement(emailFormats);
        return `${emailLocal}@${provider.domain}`;
    }
    generatePhone(language) {
        if (language === 'es') {
            // US Spanish speakers often use US phone numbers
            return faker_1.faker.phone.number('###-###-####');
        }
        else {
            return faker_1.faker.phone.number('###-###-####');
        }
    }
    generateBirthDate() {
        // Generate realistic age distribution for inheritance planning
        const ageDistribution = [
            { value: { min: 18, max: 30 }, weight: 15 }, // Young adults
            { value: { min: 30, max: 45 }, weight: 25 }, // Early career
            { value: { min: 45, max: 60 }, weight: 35 }, // Peak earning years
            { value: { min: 60, max: 80 }, weight: 20 }, // Pre/early retirement
            { value: { min: 80, max: 95 }, weight: 5 } // Elderly
        ];
        const ageRange = faker_1.faker.helpers.weightedArrayElement(ageDistribution);
        return faker_1.faker.date.birthdate({ min: ageRange.min, max: ageRange.max });
    }
    generateTimezone(language) {
        if (language === 'es') {
            // US Spanish speakers concentrated in certain regions
            const spanishTimezones = [
                'America/Los_Angeles', // California - 32% of Hispanic population
                'America/Phoenix', // Arizona
                'America/Denver', // Mountain time
                'America/Chicago', // Texas, Illinois - 30% of Hispanic population
                'America/New_York' // Florida, New York - 25% of Hispanic population
            ];
            return faker_1.faker.helpers.weightedArrayElement([
                { value: 'America/Los_Angeles', weight: 25 },
                { value: 'America/Chicago', weight: 25 },
                { value: 'America/New_York', weight: 20 },
                { value: 'America/Phoenix', weight: 15 },
                { value: 'America/Denver', weight: 15 }
            ]);
        }
        else {
            // Standard US timezone distribution
            return faker_1.faker.helpers.weightedArrayElement([
                { value: 'America/New_York', weight: 35 },
                { value: 'America/Chicago', weight: 25 },
                { value: 'America/Denver', weight: 15 },
                { value: 'America/Los_Angeles', weight: 20 },
                { value: 'America/Anchorage', weight: 3 },
                { value: 'Pacific/Honolulu', weight: 2 }
            ]);
        }
    }
    generateProfilePicture() {
        // 70% of users have profile pictures
        if (faker_1.faker.datatype.boolean(0.7)) {
            return `https://api.dicebear.com/7.x/avataaars/svg?seed=${faker_1.faker.string.alphanumeric(10)}`;
        }
        return undefined;
    }
    generateCreatedDate() {
        // Account creation over the past 2 years with recent bias
        return faker_1.faker.date.between({
            from: new Date(Date.now() - 2 * 365 * 24 * 60 * 60 * 1000),
            to: new Date()
        });
    }
    determineLanguage(preference) {
        if (preference === 'mixed') {
            // 15% Spanish, 85% English (US demographics)
            return faker_1.faker.datatype.boolean(0.15) ? 'es' : 'en';
        }
        return preference;
    }
    /**
     * Generate family relationships - useful for creating realistic FFCs
     */
    generateFamilyGroup(size, tenantId, language = 'mixed') {
        const familyLanguage = this.determineLanguage(language);
        // Generate consistent family surname
        const familySurname = this.generateLastName(familyLanguage);
        const patriarch = this.generatePatriarch(tenantId, familySurname, familyLanguage);
        const matriarch = this.generateMatriarch(tenantId, familySurname, familyLanguage);
        const numChildren = faker_1.faker.number.int({ min: 1, max: 5 });
        const children = this.generateChildren(numChildren, tenantId, familySurname, familyLanguage);
        // Some children have spouses
        const spouses = this.generateSpouses(children, tenantId, familyLanguage);
        // Some couples have children (grandchildren)
        const grandchildren = this.generateGrandchildren(children, spouses, tenantId, familyLanguage);
        return { patriarch, matriarch, children, spouses, grandchildren };
    }
    generatePatriarch(tenantId, surname, language) {
        const firstName = this.generateFirstName(language);
        return {
            ...this.generateSinglePersona(tenantId, language),
            first_name: firstName,
            last_name: surname,
            date_of_birth: faker_1.faker.date.birthdate({ min: 55, max: 85 })
        };
    }
    generateMatriarch(tenantId, surname, language) {
        const firstName = this.generateFirstName(language);
        return {
            ...this.generateSinglePersona(tenantId, language),
            first_name: firstName,
            last_name: surname,
            date_of_birth: faker_1.faker.date.birthdate({ min: 50, max: 80 })
        };
    }
    generateChildren(count, tenantId, familySurname, language) {
        return Array.from({ length: count }, () => {
            const firstName = this.generateFirstName(language);
            return {
                ...this.generateSinglePersona(tenantId, language),
                first_name: firstName,
                last_name: familySurname,
                date_of_birth: faker_1.faker.date.birthdate({ min: 25, max: 55 })
            };
        });
    }
    generateSpouses(children, tenantId, language) {
        return children
            .filter(() => faker_1.faker.datatype.boolean(0.6)) // 60% of children have spouses
            .map(() => this.generateSinglePersona(tenantId, language));
    }
    generateGrandchildren(children, spouses, tenantId, language) {
        const grandchildren = [];
        const couplesWithChildren = Math.min(children.length, spouses.length);
        for (let i = 0; i < couplesWithChildren; i++) {
            if (faker_1.faker.datatype.boolean(0.7)) { // 70% of couples have children
                const numGrandchildren = faker_1.faker.number.int({ min: 1, max: 3 });
                for (let j = 0; j < numGrandchildren; j++) {
                    const grandchild = {
                        ...this.generateSinglePersona(tenantId, language),
                        last_name: children[i].last_name,
                        date_of_birth: faker_1.faker.date.birthdate({ min: 1, max: 25 })
                    };
                    grandchildren.push(grandchild);
                }
            }
        }
        return grandchildren;
    }
}
exports.PersonaGenerator = PersonaGenerator;
